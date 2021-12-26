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

n2: pla
n:  jmp play_reflection_sound

l:  dec ball_release_timer
    bne +r
    jsr release_ball

ctrl_ball:
    lda caught_ball
    bpl -l

    ; Call the ball controller ball_speed times.
ball_loop:
    ldy ball_speed
l:  tya
    pha
    jsr ctrl_ball_subpixel
    jsr ctrl_ball_vaus
    lda has_hit_vaus
    bne -n2
    lda sprites_i,x
    bmi +e              ; Ball sprite has been removed…
    pla
    tay

    dey
    bne -l
r:  rts
e:  pla
    rts

ctrl_ball_vaus:
    lda #0
    sta has_hit_vaus

    ; Test on vertical collision with Vaus.
    lda sprites_y,x
    iny
    iny
    cmp ball_vaus_y_upper
    bcc -r
    cmp ball_vaus_y_lower
    bcs -r

    jsr get_vaus_index_in_y

    ; Test on horizontal collision with Vaus (middle pixel of ball).
    lda sprites_x,x
    clc                 ; To X centre of ball.
    adc #1
    sec
    sbc sprites_x,y
    bcc -r              ; Ball is off to the left.
    cmp vaus_width
    bcs -r
    beq -r
    tay

    lda #16
    cmp vaus_width
    bcc +n
    lda vaus_directions,y
    bne +m              ; (jmp)
n:  lda vaus_directions_extended,y
m:  sta sprites_d,x

    lda ball_vaus_y_above
    sta sprites_y,x
    lda #0
    sta sprites_d2,x

    jsr adjust_ball_speed

    lda mode
    cmp #mode_catching
    bne +r

    ; Catch ball.
    stx caught_ball
    lda #<gfx_ball_caught   ; Trick to avoid colour clash.
    sta sprites_gl,x
    lda #>gfx_ball_caught
    sta sprites_gh,x
    lda ball_vaus_y_caught
    sta sprites_y,x
    lda #delay_until_ball_is_released
    sta ball_release_timer
    lda #snd_caught_ball
    jmp play_sound

r:  inc has_hit_vaus
    rts

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
    lda #0              ; Reset from disruption bonus.
    sta mode
n:  jmp remove_sprite

ctrl_ball_subpixel:
    ; Deal with lost ball.
    lda sprites_y,x
    cmp ball_max_y
    beq lose_ball

    lda #0
    sta has_hit_brick

    ; Get centre position of ball.
    ldy sprites_x,x
    iny
    sty ball_x
    ldy sprites_y,x
    iny
    iny
    sty ball_y

    ; Quick check if foreground collision detection would
    ; detect something at all.
    tya
    and #%111
    beq +l
    cmp #%111
    beq +l
    lda ball_x
    and #%111
    beq +l
    cmp #%111
    bne +k

l:  jsr reflect
    lda has_collision
    bne +n
    jsr reflect_edge
    lda has_collision
    bne +m

k:  jsr check_hit_with_obstacle
    jsr avoid_endless_flight
    jmp half_step_smooth

    ; Deal with reflect_edge.
m:  lda #0
    sta has_collision
    lda sprites_d,x
    eor #$80                ; Opposite direction.
    sta sprites_d,x

n:  jsr adjust_ball_speed_hitting_top
    lda has_removed_brick
    beq +n

    lda level
    cmp #33
    beq +n

    ; Make bonus.
    lda mode
    cmp #mode_disruption    ; No bonuses in disruption mode.
    beq +l
    jsr make_bonus
    jmp +l

n:  lda has_hit_silver_brick
    ora has_hit_golden_brick
    bne +f
    lda has_hit_brick
    bne +f
    lda #0
    sta sprites_d2,x
    jmp +l

f:  inc sprites_d2,x

l:  jsr apply_reflection
    jsr play_reflection_sound
    jmp half_step_smooth

play_reflection_sound:
    lda has_hit_vaus
    beq +n
    lda #snd_reflection_low
    bne +l
n:  lda has_hit_brick
    beq +r
    lda has_hit_golden_brick
    ora has_hit_silver_brick
    beq +n
    lda #snd_reflection_silver
    bne +l
n:  lda #snd_reflection_high
l:  jmp play_sound
r:  rts

check_hit_with_obstacle:
    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and #is_obstacle
    beq +n
f:  lda sprites_x,y
    cmp ball_x
    bcs +n
    lda sprites_y,y
    cmp ball_y
    bcs +n
    lda sprites_x,y
    clc
    adc #8
    cmp ball_x
    bcc +n
    lda sprites_y,y
    clc
    adc #16
    cmp ball_y
    bcc +n

    lda #0
    sta sprites_d2,x
    jsr reflect_ball_obstacle
    jsr apply_reflection_unconditionally
    jsr remove_obstacle
    jmp adjust_ball_speed

n:  dey
    bpl -l
    rts

avoid_endless_flight:
    lda sprites_d2,x
    cmp #64
    bcc +r
    lda #0
    sta sprites_d2,x
    lda framecounter
    lsr
    bcc +n
    lda sprites_d,x
    jsr turn_clockwise
    jmp +l
n:  lda sprites_d,x
    jsr turn_counterclockwise
l:  sta sprites_d,x
r:  rts

make_ball:
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    sta caught_ball
    tax
    lda #59
    sta sprites_x,x
    lda ball_vaus_y_caught
    sta sprites_y,x
    lda #<gfx_ball_caught
    sta sprites_gl,x
    lda #>gfx_ball_caught
    sta sprites_gh,x
    lda #default_ball_direction
    sta sprites_d,x
    lda #0
    sta sprites_d2,x
    lda #initial_delay_until_ball_is_released
    sta ball_release_timer
    rts

; From arcade ROM (check code at 0x1442 and this table at 0x1462).
ball_speeds_when_top_hit:
    7 7 8 0 7 7 7 0 7 5
    7 7 8 6 7 5 7 7 7 0
    7 0 0 0 0 7 8 7 0 7
    0 0 0 0

adjust_ball_speed_hitting_top:
    lda sprites_y,x
    cmp ball_min_y
    bne +n
    ldy level
    lda @(-- ball_speeds_when_top_hit),y
    cmp ball_speed
    bcc +n
    ldy is_using_paddle
    bne +l
    cmp #max_ball_speed_joystick_top
    bcc +l
    lda #max_ball_speed_joystick_top
l:  sta ball_speed
n:  rts

ball_accelerations_after_brick_hits:
    $00 $19 $19 $23 $23 $2d $3c $50 $78 $8c $a0 $b4 $c8 $dc $f0 $ff

adjust_ball_speed:
    inc num_hits
    ldy #0
l:  lda ball_accelerations_after_brick_hits,y
    cmp num_hits
    beq increase_ball_speed
    iny
    cpy #16
    bne -l
    beq +n      ; (jmp)

increase_ball_speed:
    lda ball_speed
    ldy is_using_paddle
    bne +m
    cmp #max_ball_speed_joystick
    bcs +n
    bcc +l                  ; (jmp)
m:  cmp #max_ball_speed
    bcs +n                  ; Already at maximum speed. Do nothing…
l:  inc ball_speed          ; Play the blues…
n:  rts

release_ball:
    ldy caught_ball
    lda ball_vaus_y_above
    sta sprites_y,y

    ; Correct X position so the ball won't end up in the wall.
    lda sprites_x,y
    cmp ball_max_x
    bcc +n
    lda ball_max_x
    sta sprites_x,y
n:  cmp #7
    bcs +n
    lda #8
    sta sprites_x,y

n:  lda #255
    sta caught_ball
    lda #snd_reflection_low
    jmp play_sound
