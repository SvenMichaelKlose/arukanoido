ctrl_vaus:
    lda mode_break
    beq +n      ; Not active.
    bmi +n      ; Active but Vaus is not moving through the gate.

    ; Break mode: move Vaus out through the port.
    lda framecounter
    and #7
    bne +m
    lda sprites_x,x
    cmp ball_max_x
    bcs +m
    lda #2              ; (1 multi-color pixel)
    jsr sprite_right
m:  lda #<score_100
    sta s
    lda #>score_100
    sta @(++ s)
    jsr add_to_score
    dec mode_break      ; Start animation.
    bne -r
    lda #0              ; Signal end of game to main loop.
    sta bricks_left
    jmp remove_sprite

    ; Check on collision with obstacle.
n:  lda #is_obstacle
    jsr find_hit
    bcs +n
    jsr remove_obstacle
n:

    ; Determine paddle move distance.
    lda $9008
    sec
    sbc old_paddle_value
    jsr abs
    and #%11111110
    sta paddle_move_distance

    ; Check if paddle is being used.
    lda is_using_paddle
    bne handle_paddle
    lda paddle_move_distance
    beq handle_joystick

    sta is_using_paddle
    lda $9008
    sta old_paddle_value

handle_paddle:
    ldy $9008
    sty old_paddle_value
    ; Take paddle value as centre of the Vaus.
    lda vaus_width
    lsr
    jsr neg
    clc
    adc paddle_xlat,y
    bmi +n2     ; Extended Vaus clipping over left wall.
    cmp #8
    bcs +n
n2: lda #8
n:  jsr test_vaus_hit_right
    bcc +n

    ldy mode_break
    beq +m
    jmp enter_break_mode

m:  lda #@(* 14 8)
    sec
    sbc vaus_width
n:  sec
    sbc sprites_x,x
    sta tmp2
    jsr sprite_right

    ; Move caught ball relative to Vaus.
    lda caught_ball
    bmi +n
    stx tmp
    tax
    lda tmp2
    jsr sprite_right
    ldx tmp

n:  lda $9111
    and #joy_left
    beq do_fire

done:
    lda sprites_x,x
    beq +r
    sta vaus_last_x
r:  rts

handle_joystick:
    ; Joystick left.
n:  lda $9111
    and #joy_left
    bne +n
    jsr move_vaus_left
    jmp handle_joystick_fire

    ; Joystick right.
n:  lda #0          ; Fetch rest of joystick status.
    sta $9122
    ldy #255
    lda $9120
    sty $9122
    bmi handle_joystick_fire
    jsr move_vaus_right

handle_joystick_fire:
    lda $9111
    and #joy_fire
    beq do_fire

    jsr get_keypress
    bcc -done
    cmp #keycode_s
    beq +l
    cmp #keycode_j
    bne +n
l:  jsr move_vaus_left
    jmp -done

n:  cmp #keycode_d
    beq +l
    cmp #keycode_k
    bne +n
l:  jsr move_vaus_right
    jmp -done

n:  cmp #keycode_space
    bne -done

do_fire:
    ;; Catching mode
    ; Release caught ball. Shallow ball angle when moving to the right.
    ldy caught_ball
    bmi +n      ; None caught…

    lda mode
    cmp #mode_catching
    beq +m

    lda is_using_paddle
    bne +l

    lda vaus_last_x
    cmp sprites_x,x
    beq +m
o:  lda #initial_ball_direction_skewed
    sta sprites_d,y
m:  jmp release_ball

l:  lda paddle_move_distance
    bne -o
    beq -m  ; (jmp)

done2:
    jmp -done

    ;; Laser mode
n:  lda mode
    cmp #mode_laser
    bne -done2

    lda is_firing
    bne +r

n:  lda #snd_laser
    jsr play_sound
    ldy #laser_delay_short
    lda laser_delay_type
    lsr
    bcc +n
    ldy #laser_delay_long
n:  sty is_firing
    inc laser_delay_type
    lda sprites_x,x
    clc
    adc #4
    sta @(+ laser_init sprite_init_x)
    ldy #@(- laser_init sprite_inits)
    jsr add_sprite
    tay
    lda vaus_y
    sta sprites_y,y
    jmp -done

move_vaus_left:
    txa
    pha
    ldx vaus_sprite_index
    lda sprites_x,x
    cmp #9
    bcc +n
    lda #2
    jsr sprite_left

    ; Move caught ball with Vaus.
    lda caught_ball
    bmi +n
    tax
    lda #2
    jsr sprite_left
n:  pla
    tax
r:  rts

move_vaus_right:
    txa
    pha
    ldx vaus_sprite_index
    lda sprites_x,x
    jsr test_vaus_hit_right
    bcs +e
    lda #2
    jsr sprite_right

    ; Move caught ball with Vaus.
    lda caught_ball
    bmi +n
    tax
    lda #2
    jsr sprite_right
n:  pla
    tax
    rts

e:  pla

    ;; Break mode
enter_break_mode:
    lda mode_break
    beq +n

    lda #@(+ is_ball is_bonus is_obstacle is_laser)
    jsr remove_sprites_by_type

    lda #100
    sta mode_break
    lda #snd_round_break
    jmp play_sound

n:  lda #@(* 14 8)
    sec
    sbc vaus_width
    sta sprites_x,x
    rts

make_vaus:
    ldy #@(- vaus_init sprite_inits)
    jsr add_sprite
    sta vaus_sprite_index
    tax
    lda #vaus_x
    sta sprites_x,x
    sta vaus_last_x
    lda vaus_y
    sta sprites_y,x
    rts

test_vaus_hit_right:
    ldy mode
    cpy #mode_extended
    bne +n
    cmp #@(* (- 15 4) 8)
    rts
n:  cmp #@(* (- 15 3) 8)
r:  rts
