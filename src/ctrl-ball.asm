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
    lda ball_speed
    sta ctrl_ball_tmp
l:  lda sprites_i,x
    bmi +r
    lda #0
    sta position_has_changed
    jsr half_step_smooth
    ; Ball moves half a pixel maximum, so don't call the
    ; controller for nothing.
    lda position_has_changed
    beq +n
    jsr ctrl_ball_subpixel
n:  dec ctrl_ball_tmp
    bne -l
r:  rts

jmp_check_reflection:
    jmp check_reflection

hit_vaus:
    ;; Ignore ball if it's not headed downwards.
    lda sprites_d,x
    sec
    sbc #64
    bpl jmp_check_reflection

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
    lda #<score_100
    sta sl
    lda #>score_100
    sta sh
    jsr add_to_score
    lda #0
    sta sprites_d2,x    ; Reset number of hits with no effect.
    lda #192
    sta side_degrees
    jsr apply_reflection_unconditionally
    jmp remove_obstacle

lose_ball:
    pla
    pla
    dec balls
    bne +n

    ;; End game.
    lda #0
    sta is_running_game
    lda #snd_miss
    jmp play_sound

    ;; Undo Disruption Mode if 1 ball left.
n:  lda balls
    cmp #1
    bne +n
    lda #0
    sta mode

    ;; Remove ball.
n:  jmp remove_sprite

ctrl_ball_subpixel:
    lda #0
    sta has_hit_brick

    ;; Get centre position of ball.
    ldy sprites_x,x
    iny
    sty ball_x
    ldy sprites_y,x
    cpy ball_max_y
    beq lose_ball
    iny
    iny
    sty ball_y

    ;; Hit Vaus or obstacle?
    lda #@(+ is_vaus is_obstacle)
    jsr find_point_hit
    bcs check_reflection    ; No…
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
    bne +n                  ; Ball hit something…

    ;; Edge hit instead?
    jsr reflect_edge
    lda has_reflection
    beq -r                  ; Nothing hit.  Done…
    lda #0
    sta has_reflection
    lda sprites_d,x
    eor #$80                ; Opposite direction.
    sta sprites_d,x

    ;; Adjust ball speed when it hits the top of the arena
    ;; depending on round number.
n:  lda sprites_y,x
    cmp ball_min_y
    bne regular_speed_adjustment
    ldy level
    lda @(-- ball_speeds_when_top_hit),y
    cmp ball_speed
    bcc regular_speed_adjustment
    ldy is_using_paddle
    bne +n
    cmp #max_ball_speed_joystick
    bcc +n
    lda #max_ball_speed_joystick
n:  sta ball_speed
    bne handle_removed_brick ; (jmp)

regular_speed_adjustment:
    jsr adjust_ball_speed

handle_removed_brick:
    lda has_removed_brick
    beq +n

    ;; Handle DOH.
    lda is_doh_level    ; TODO: Remove?
    bne +n

    ;; Make bonus.
    lda mode
    cmp #mode_disruption    ; No bonuses in disruption mode.
    beq handle_reflection
    jsr make_bonus
    jmp handle_reflection

    ;;; Divert ball if it got stuck.
n:  lda has_hit_silver_brick
    ora has_hit_golden_brick
    bne maybe_stuck
    lda has_hit_brick
    bne maybe_stuck
    sta sprites_d2,x
    beq handle_reflection ; (jmp)

maybe_stuck:
    inc sprites_d2,x    ; Increment stickyness.
    lda sprites_d2,x
    cmp #max_ball_stickyness
    bcc handle_reflection

    ;; Divert ball a step.
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

handle_reflection:
    jsr apply_reflection

play_reflection_sound:
    lda has_hit_brick
    beq +r
    lda is_doh_level
    beq +n
    lda #snd_hit_doh
    bne jmp_play_sound ; (jmp)
    ; Special sound for gold or silver brick.
n:  lda has_hit_golden_brick
    ora has_hit_silver_brick
    beq +n
    lda #snd_reflection_silver
    bne jmp_play_sound  ; (jmp)
    ; Regular.
n:  lda #snd_reflection_high
jmp_play_sound:
    jmp play_sound

;;; Make first ball of a round.
make_ball:
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    sta caught_ball ; (Just in case.)
    tax
    lda #59

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
