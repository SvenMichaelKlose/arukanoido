    0 0
vaus_directions:
    168
    168 168 168 168
    138 138 138 138
    116 116 116 116
    88 88 88 88
    88

    0 0

vaus_directions_extended:
    168
    168 168 168 168
    168 168 168 168
    138 138 138 138
    138 138 138 138
    116 116 116 116
    116 116 116 116
    88 88 88 88
    88 88 88 88
    88

    0 0

l:  dec ball_release_timer
    bne +r
    jsr release_ball

ctrl_ball:
    lda caught_ball
    bpl -l

    ; Call the ball controller ball_speed times.
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

ctrl_ball_subpixel:
    lda #0
    sta has_hit_vaus

    ; Test on vertical collision with Vaus.
    lda sprites_y,x
    cmp #@(- vaus_y ball_height -1)
    bcc no_vaus_hit
    cmp #@(+ vaus_y 8)
    bcs no_vaus_hit

    ; Test on horizontal collision with Vaus (middle pixel).
    ldy sprites_x,x
    iny
    sty tmp
    ldy @(+ sprites_x (-- num_sprites))     ; Vaus position left.
    dey                 ; Allow one pixel off to the left.
    sty tmp2
    cpy tmp
    bcs +no_vaus_hit

h:  lda tmp2
    clc
    adc #1              ; Allow a pixel off to the right as well.
    adc vaus_width
    cmp tmp
    bcc +no_vaus_hit

    inc has_hit_vaus

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
    sta reflections_since_last_vaus_hit

    lda mode
    cmp #mode_catching
    bne +n

    ; Catch ball.
    stx caught_ball
    lda #<gfx_ball_caught
    sta sprites_gl,x
    lda #>gfx_ball_caught
    sta sprites_gh,x
    lda #@(* 28 8)
    sta sprites_y,x
    jsr applied_reflection
    lda #delay_until_ball_is_released
    sta ball_release_timer
    lda #snd_caught_ball
    jmp play_sound

n:  jmp applied_reflection

no_vaus_hit:
    jsr reflect
    lda has_collision
    bne +n
m:  jsr avoid_endless_flight
    jmp move_ball
n:

    lda has_hit_brick
    beq hit_solid

    lda #0
    sta reflections_since_last_vaus_hit

    ; Make bonus.
    lda mode
    cmp #mode_disruption    ; No bonuses in disruption mode.
    beq do_apply_reflection
    jsr make_bonus
    jmp do_apply_reflection

hit_solid:
    inc reflections_since_last_vaus_hit

do_apply_reflection:
    jsr apply_reflection

applied_reflection:
    ; Determine reflection sound.
    lda has_hit_brick
    ora has_hit_vaus
    beq +move_ball
    lda snd_reflection
    bne +n
    lda sfx_reflection
    and #1
    clc
    adc #snd_reflection_low
    sta snd_reflection
n:  inc sfx_reflection

move_ball:
    ; Move a full pixel at most.
    jsr ball_step
    jsr ball_step

    ; Deal with lost ball.
    lda sprites_y,x
    cmp #@(- (* 8 screen_rows) 4)
    bcc play_reflection_sound

    dec balls
    bne still_balls_left

    lda #0
    sta is_running_game
    lda #snd_miss
    jmp play_sound

still_balls_left:
    lda balls
    cmp #1
    bne +r
    lda #0              ; Reset from disruption bonus.
    sta mode
r:  jmp remove_sprite

play_reflection_sound:
    lda has_hit_brick
    ora has_hit_golden_brick
    ora has_hit_vaus
    beq +n
    lda snd_reflection
    beq +n
    ldx #0
    stx snd_reflection
    jmp play_sound
n:

    ; Hit obstacle?
    jsr find_hit
    bcs +n
    lda sprites_i,y
    and #is_obstacle
    beq +n
    jsr reflect_ball_obstacle
    jsr apply_reflection
    jsr remove_obstacle
    jsr increase_ball_speed
n:
    rts

avoid_endless_flight:
    lda reflections_since_last_vaus_hit
    cmp #32
    bcc +r
    lda sprites_d,x
    and #%00100000
    bne +n
    lda sprites_d,x
    clc
    adc #8
    sta sprites_d,x
    rts
n:  lda sprites_d,x
    sec
    sbc #8
    sta sprites_d,x
r:  rts

ball_step:
    ; Move on X axis.
    ldy sprites_d,x
    lda ball_directions_x,y
    bmi +m
    lda sprites_dx,x
    clc
    adc ball_directions_x,y
    bcc +n
    inc sprites_x,x
    jmp +n

m:  jsr neg
    sta tmp
    lda sprites_dx,x
    sec
    sbc tmp
    bcs +n
    dec sprites_x,x

n:  sta sprites_dx,x

    ; Move on Y axis.
    lda ball_directions_y,y
    bmi +m
    lda sprites_dy,x
    clc
    adc ball_directions_y,y
    bcc +n
    inc sprites_y,x
    jmp +n

m:  jsr neg
    sta tmp
    lda sprites_dy,x
    sec
    sbc tmp
    bcs +n
    dec sprites_y,x

n:  sta sprites_dy,x
    rts

make_ball:
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    sta caught_ball
    tax
    lda #70
    sta sprites_x,x
    lda #@(* 28 8)
    sta sprites_y,x
    lda #<gfx_ball_caught
    sta sprites_gl,x
    lda #>gfx_ball_caught
    sta sprites_gh,x
    lda #default_ball_direction
    sta sprites_d,x
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
n:

    lda #255
    sta caught_ball
    lda #snd_reflection_low
    jsr play_sound
    lda #0
    sta sfx_reflection
    rts
