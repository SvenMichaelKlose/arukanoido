vaus_directions:
    direction_ls direction_ls direction_ls direction_ls
    direction_l direction_l direction_l direction_l
    direction_r direction_r direction_r direction_r
    direction_rs direction_rs direction_rs direction_rs

vaus_directions_extended:
    direction_ls direction_ls direction_ls direction_ls
    direction_l direction_l direction_l direction_l
    direction_l direction_l direction_l direction_l
    direction_r direction_r direction_r direction_r
    direction_r direction_r direction_r direction_r
    direction_rs direction_rs direction_rs direction_rs

used_ball_directions:
    direction_ls
    direction_l
    direction_r
    direction_rs
    @(byte (+ 128 direction_ls))
    @(byte (+ 128 direction_l))
    @(byte (+ 128 direction_r))
    @(byte (+ 128 direction_rs))

get_used_ball_direction:
    ldy #7
l:  cmp used_ball_directions,y
    beq +r
    dey
    bpl -l     ; (jmp)
r:  rts

turn_clockwise:
    jsr get_used_ball_direction
    iny
l:  tya
    and #7
    tay
    lda used_ball_directions,y
    rts

turn_counterclockwise:
    jsr get_used_ball_direction
    dey
    jmp -l

loosen_caught_ball:
    dec ball_release_timer
    bne +r
    jsr release_ball

ctrl_ball:
    lda caught_ball
    bpl loosen_caught_ball

    ;; Call the ball controller ball_speed times.
    ldy ball_speed
l:  lda sprites_i,x
    bmi +r
    tya
    pha
    ; Move it.
    jsr half_step_smooth
    ; Ball moves half a pixel maximum, so don't call the
    ; controller for nothing.
    lda position_has_changed
    beq +n
    jsr ctrl_ball_subpixel
n:  pla
    tay
    dey
    bne -l
r:  rts

l:  jmp check_reflection

hit_vaus:
    ;; Ignore ball if it's not headed downwards.
    lda sprites_d,x
    sec
    sbc #64
    bpl -l

    ;; Get relative X position to Vaus
    ;; which is our reflection table index.
    lda ball_x
    sec
    sbc sprites_x,y
    tay

    ;; Get direction to reflect from Vaus.
    ; Choose between normal and exended Vaus'
    ; relection table.
    lda mode
    cmp #mode_extended
    beq +n
    lda vaus_directions,y
    bne +m              ; (jmp)
n:  lda vaus_directions_extended,y
    ; Save new ball direction.
m:  sta sprites_d,x
    lda #0
    sta sprites_d2,x

    jsr adjust_ball_speed

    ;; Check if ball has to be catched.
    lda mode
    cmp #mode_catching
    bne +r

    ;; Catch ball.
    stx caught_ball
    jsr set_caught_ball_gfx
    lda ball_vaus_y_caught
    sta sprites_y,x
    lda #delay_until_ball_is_released
    sta ball_release_timer
    lda #snd_caught_ball
    jmp play_sound

    ;; Play sound and finish.
r:  lda #snd_reflection_low
    jmp play_sound

hit_obstacle:
    lda #0
    sta sprites_d2,x    ; Reset number of hits with no effect.
    jsr reflect_ball_obstacle
    jsr apply_reflection_unconditionally
    jmp remove_obstacle

lose_ball:
    pla
    pla
    pla
    dec balls
    bne +n
    lda #0
    sta is_running_game
    lda #snd_miss
    jmp play_sound

n:  lda balls
    cmp #1
    bne +n
    lda #0              ; Undo disruption mode.
    sta mode
n:  jmp remove_sprite

ctrl_ball_subpixel:
    ;; Deal with lost ball.
    lda sprites_y,x
    cmp ball_max_y
    beq lose_ball

    lda #0
    sta has_hit_brick

    ;; Get centre position of ball.
    ldy sprites_x,x
    iny
    sty ball_x
    ldy sprites_y,x
    iny
    iny
    sty ball_y

    ;; Hit Vaus or obstacle?
    lda #@(+ is_vaus is_obstacle)
    jsr find_point_hit
    bcs check_reflection    ; Nothing hit…
    lda sprites_i,y
    and #is_vaus
    beq hit_obstacle
    jmp hit_vaus

r:  rts

    ;;; Hit char?
check_reflection:
    ;; Side hit?
    jsr reflect
    lda has_reflection
    bne +n2                     ; Ball hit something…

    ;; Edge hit instead?
    jsr reflect_edge
    lda has_reflection
    beq -r
m:  lda #0
    sta has_reflection
    lda sprites_d,x
    eor #$80                ; Opposite direction.
    sta sprites_d,x

n2: jsr adjust_ball_speed_hitting_top

    ;;; Handle removed brick.
    lda has_removed_brick
    beq +n
    lda level
    cmp #33
    beq +n
    ;; Make bonus.
    lda mode
    cmp #mode_disruption    ; No bonuses in disruption mode.
    beq +l
    jsr make_bonus
    jmp +l

    ;;; Divert ball if it got stuck.
n:  lda has_hit_silver_brick
    ora has_hit_golden_brick
    bne +f
    lda has_hit_brick
    bne +f
    sta sprites_d2,x
    beq +l                  ; (jmp)
f:  inc sprites_d2,x
    lda sprites_d2,x
    cmp #64
    bcc +l
    ;; Divert ball as it had 64 hits with no effect.
    lda #0
    sta sprites_d2,x
    ; Random pick if (counter) clock-wise.
    lda framecounter
    lsr
    bcc +n
    lda sprites_d,x
    jsr turn_clockwise
    jmp +l2
n:  lda sprites_d,x
    jsr turn_counterclockwise
l2: sta sprites_d,x

l:  jsr apply_reflection

play_reflection_sound:
    lda has_hit_brick
    beq +r
    lda is_doh_level
    beq +n
    lda #snd_hit_doh
    bne +l  ; (jmp)
    ; Special sound for gold or silver brick.
n:  lda has_hit_golden_brick
    ora has_hit_silver_brick
    beq +n
    lda #snd_reflection_silver
    bne +l  ; (jmp)
    ; Regular.
n:  lda #snd_reflection_high
l:  jmp play_sound

;;; Make first ball of a round.
make_ball:
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    sta caught_ball ; (Just in case.)
    tax
    lda #59
    sta sprites_x,x
    lda ball_vaus_y_caught
    sta sprites_y,x
    jsr set_caught_ball_gfx
    lda #initial_ball_direction
    sta sprites_d,x
    lda #0
    sta sprites_d2,x
    lda #delay_until_forced_release
    sta ball_release_timer
r:  rts

;;; Adjust ball speed when it hits the top of the arena
;;; depending on round number.
adjust_ball_speed_hitting_top:
    lda sprites_y,x
    cmp ball_min_y
    bne adjust_ball_speed
    ldy level
    lda @(-- ball_speeds_when_top_hit),y
    cmp ball_speed
    bcc adjust_ball_speed
    ldy is_using_paddle
    bne +l
    cmp #max_ball_speed_joystick
    bcc +l
    lda #max_ball_speed_joystick
l:  sta ball_speed
    rts

;;; From arcade ROM (check code at 0x1442 and this table at 0x1462).
ball_speeds_when_top_hit:
    7 7 8 0 7 7 7 0 7 5
    7 7 8 6 7 5 7 7 7 0
    7 0 0 0 0 7 8 7 0 7
    0 0 0 0

;;; Adjust ball speed depending on number of collisions.
adjust_ball_speed:
    ldy ball_speed
    cpy #$0f
    beq +r          ; Maximum ball speed already…
    lda sprites_d,x
    clc
    adc #64
    bpl +l          ; Reflecting upwards, may accelerate…
    lda sprites_y,x
    sec
    sbc arena_y
    cmp #@(* 8 14)
    bcs +r          ; Do not accelerate on bottom half of screen.

l:  tya
    lsr
    tay
    inc num_hits
    lda num_hits
    cmp ball_accelerations,y
    bcc +r

    ;; Increase ball speed.
    lda #0
    sta num_hits

increase_ball_speed:
    lda ball_speed
    ldy is_using_paddle
    bne +n
    cmp #max_ball_speed_joystick
    bcs +r
    bcc +l                  ; (jmp)
n:  cmp #max_ball_speed
    bcs +r                  ; Already at maximum speed. Do nothing…
l:  inc ball_speed          ; Play the blues…
r:  rts

;;; From arcade ROM.
ball_accelerations:
    $00 $19 $19 $23 $23 $2d $3c $50 $78 $8c $a0 $b4 $c8 $dc $f0

;;; Release caught ball.
release_ball:
    ldy caught_ball
    lda ball_vaus_y_above
    sta sprites_y,y
    ; Undo colour clash avoidance.
    lda #<gfx_ball
    sta sprites_gl,y
    lda #>gfx_ball
    sta sprites_gh,y
    lda preshifted_ball
    sta sprites_pgl,y
    lda @(++ preshifted_ball)
    sta sprites_pgh,y

    ; Correct X position so the ball won't end up within the wall.
    lda sprites_x,y
    cmp #ball_max_x
    bcc +n
    lda #@(-- ball_max_x)
    sta sprites_x,y
n:  cmp #7
    bcs +n
    lda #8
    sta sprites_x,y

n:  lda #255
    sta caught_ball
    lda #snd_reflection_low
    jmp play_sound

set_caught_ball_gfx:
    lda #<gfx_ball_caught
    sta sprites_gl,x
    lda #>gfx_ball_caught
    sta sprites_gh,x
    lda preshifted_ball_caught   ; Trick to avoid colour clash.
    sta sprites_pgl,x
    lda @(++ preshifted_ball_caught)
    sta sprites_pgh,x
    rts
