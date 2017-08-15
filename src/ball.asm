vaus_directions:
    direction_ls
    direction_ls direction_ls direction_ls direction_ls
    direction_l direction_l direction_l direction_l
    direction_r direction_r direction_r direction_r
    direction_rs direction_rs direction_rs direction_rs
    direction_rs

vaus_directions_extended:
    direction_ls
    direction_ls direction_ls direction_ls direction_ls
    direction_l direction_l direction_l direction_l
    direction_l direction_l direction_l direction_l
    direction_r direction_r direction_r direction_r
    direction_r direction_r direction_r direction_r
    direction_rs direction_rs direction_rs direction_rs
    direction_rs

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
    jmp -l
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


n:  jmp play_reflection_sound

l:  dec ball_release_timer
    bne +r
    jsr release_ball

ctrl_ball:
    lda caught_ball
    bpl -l

    jsr ctrl_ball_vaus
    lda has_hit_vaus
    bne -n

    ; Deal with lost ball.
    lda sprites_y,x
    cmp #@(- (* 8 screen_rows) 4)
    bcc +ball_loop

    dec balls
    bne +n
    lda #0
    sta is_running_game
    lda #snd_miss
    jmp play_sound
n:

    lda balls
    cmp #1
    bne +n
    lda #0              ; Reset from disruption bonus.
    sta mode
n:  jmp remove_sprite

    ; Call the ball controller ball_speed times.
ball_loop:
    ldy ball_speed
l:  tya
    pha
    jsr ctrl_ball_subpixel
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
    cmp #@(- vaus_y ball_height -1)
    bcc -r
    cmp #@(+ vaus_y 8)
    bcs -r

    jsr get_vaus_index_in_y

    ; Test on horizontal collision with Vaus (middle pixel).
    lda sprites_x,x
    clc
    adc #1
    sta tmp
    lda sprites_x,y
    sec                 ; Allow one pixel off to the left.
    sbc #1
    sta tmp2
    cmp tmp
    bcs -r

    lda tmp2
    clc
    adc #1              ; Allow a pixel off to the right as well.
    adc vaus_width
    cmp tmp
    bcc -r

    ; Get reflection from Vaus.
    lda tmp
    sec
    sbc tmp2
    tay

    lda #16
    cmp vaus_width
    bcc +n
    lda vaus_directions,y
    jmp +m
n:  lda vaus_directions_extended,y
m:  sta sprites_d,x

    lda #@(- vaus_y ball_height)
    sta sprites_y,x

    lda #0
    sta sprites_d2,x

    lda mode
    cmp #mode_catching
    bne +r

    ; Catch ball.
    stx caught_ball
    lda #<gfx_ball_caught   ; Trick to avoid colour clash.
    sta sprites_gl,x
    lda #>gfx_ball_caught
    sta sprites_gh,x
    lda #@(* 28 8)
    sta sprites_y,x
    lda #delay_until_ball_is_released
    sta ball_release_timer
    lda #snd_caught_ball
    jmp play_sound

r:  inc has_hit_vaus
    rts

ctrl_ball_subpixel:
    lda #0
    sta has_hit_brick
    jsr reflect
    lda has_collision
    bne +n
    jsr reflect_edge
    lda has_collision
    bne +m

    jsr check_hit_with_obstacle
    jsr avoid_endless_flight
    jmp step_smooth

    ; Deal with edge collision.
m:  lda #0
    sta has_collision
    lda sprites_d,x
    clc
    adc #$80
    sta sprites_d,x

n:  lda has_removed_brick
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
    jmp step_smooth

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
    ; Get centre of ball.
    ldy sprites_x,x
    iny
    sty tmp
    ldy sprites_y,x
    iny
    iny
    sty tmp2
    
    ; Hit obstacle?
    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and #is_obstacle
    beq +n
f:  lda sprites_x,y
    cmp tmp
    bcs +n
    lda sprites_y,y
    cmp tmp2
    bcs +n
    lda sprites_x,y
    clc
    adc #8
    cmp tmp
    bcc +n
    lda sprites_y,y
    clc
    adc #16
    cmp tmp2
    bcc +n

    lda #0
    sta sprites_d2,x
    jsr reflect_ball_obstacle
    jsr apply_reflection
    jsr remove_obstacle
    jmp increase_ball_speed

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
    lda #@(* 28 8)
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

ball_accelerations_after_brick_hits:
    $00 $0a $0f $14 $1e $28 $37 $50 $6e $87 $a0 $b9 $d2 $e6 $f5 $ff ; TODO: Check if $ff really terminates.

adjust_ball_speed:
    ldy #0
l:  lda ball_accelerations_after_brick_hits,y
    cmp #$ff
    beq +n
    cmp num_brick_hits
    beq +l
    iny
    jmp -l

increase_ball_speed:
l:  lda ball_speed
    ldy is_using_paddle
    bne +m
    cmp #max_ball_speed_joystick
    bcs +n
    bcc +l
m:  cmp #max_ball_speed
    bcs +n                  ; Already at maximum speed. Do nothing…
l:  inc ball_speed          ; Play the blues…
n:  rts

release_ball:
    ; Correct X position so the ball won't end up in the border.
    ldy caught_ball
    lda sprites_x,y
    cmp #@(- (* (-- screen_columns) 8) 3)
    bcc +n
    lda #@(- (* (-- screen_columns) 8) 3)
    sta sprites_x,y                                                                                               
n:  cmp #7
    bcs +n
    lda #8
    sta sprites_x,y

n:  lda #255
    sta caught_ball
    lda #snd_reflection_low
    jsr play_sound
    rts
