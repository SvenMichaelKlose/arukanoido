get_vaus_index_in_x:
    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    and #is_vaus
    bne +r
    dex
    bpl -l
r:  rts

get_vaus_index_in_y:
    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and #is_vaus
    bne +r
    dey
    bpl -l
r:  rts

ctrl_dummy:
    rts

test_vaus_hit_right:
    ldy mode
    cpy #mode_extended
    bne +n
    cmp #@(* (- screen_columns 4) 8)
    bcs +r
    bcc +r
n:  cmp #@(* (- screen_columns 3) 8)
r:  rts

ctrl_vaus:
    ; Check on collision with obstacle.
    jsr find_hit
    bcs +n
    lda sprites_i,y
    and #is_obstacle
    beq +n
    jsr remove_obstacle
n:

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    sta joystick_status

    lda is_using_paddle
    bne handle_paddle

    ; Check if paddle is being used.
    lda $9008
    sec
    sbc old_paddle_value
    jsr abs
    and #%11111000
    beq handle_joystick
    lda #1
    sta is_using_paddle

handle_paddle:
    ldy $9008
    lda paddle_xlat,y
    jsr test_vaus_hit_right
    bcc +n

    ldy mode_break
    beq +m
    lda #0
    sta bricks_left
    rts

m:  lda #@(* (- screen_columns 1) 8)
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

n:  lda joystick_status
    and #joy_left
    beq do_fire

done:
    lda sprites_x,x
    sta vaus_last_x
    rts

handle_joystick:
    ; Joystick left.
n:  lda joystick_status
    and #joy_left
    bne +n
    lda sprites_x,x
    cmp #9
    bcc +n
    lda #2
    jsr sprite_left

    lda caught_ball
    bmi handle_joystick_fire
    stx tmp
    tax
    lda #2
    jsr sprite_left
    ldx tmp
    jmp handle_joystick_fire

done2:
    jmp -done

    ; Joystick right.
n:  lda #0          ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi handle_joystick_fire
    lda sprites_x,x
    jsr test_vaus_hit_right
    bcs handle_break_mode
    lda #2
    jsr sprite_right

    lda caught_ball
    bmi handle_joystick_fire
    stx tmp
    tax
    lda #2
    jsr sprite_right
    ldx tmp

handle_joystick_fire:
    lda joystick_status
    and #joy_fire
    bne -done

do_fire:
    ldy caught_ball
    bmi +n
    lda sprites_d,y
    cmp #default_ball_direction
    bne +m
    lda vaus_last_x
    cmp sprites_x,x
    bcs +m
    beq +m
    lda #default_ball_direction_skewed
    sta sprites_d,y
m:  lda #@(- (* 29 8) 5)
    sta sprites_y,y
    lda #<gfx_ball
    sta sprites_gl,y
    lda #>gfx_ball
    sta sprites_gh,y
    lda #snd_reflection_low
    jsr play_sound
n:  lda #255
    sta caught_ball

    lda mode
    cmp #mode_laser
    bne -done2

    lda is_firing
    beq +n
    dec is_firing
    bne +r

n:  lda #snd_laser
    jsr play_sound
    lda #9              ;  TODO: constant fire_delay
    sta is_firing
    lda sprites_x,x
    clc
    adc #4
    sta @(+ laser_init sprite_init_x)
    ldy #@(- laser_init sprite_inits)
    jmp add_sprite

handle_break_mode:
    lda mode_break
    beq +n

    ; Remove all sprites except the Vaus.
    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and #is_vaus
    bne +m
    lda #is_inactive
    sta sprites_i,y
m:  dey
    bpl -l

    lda #snd_round_break
    jsr play_sound
    lda #0
    sta bricks_left
    rts

n:  lda #@(* (- screen_columns 1) 8)
    sec
    sbc vaus_width
    sta sprites_x,x
r:  rts

make_vaus:
    ldy #@(- vaus_init sprite_inits)
    jsr add_sprite

set_vaus_color:
    lda mode
    cmp #mode_laser
    bne +r
    ldy #<gfx_vaus
    lda framecounter
    lsr
    bcs +n
    ldy #<gfx_vaus_laser
n:  tya
    pha
    jsr get_vaus_index_in_y
    pla
    sta sprites_gl,y
r:  rts
