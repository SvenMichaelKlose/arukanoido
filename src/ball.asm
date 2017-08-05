vaus_directions:
    168
    168 168 168 168
    140 140 140 140
    116 116 116 116
    88 88 88 88
    88

vaus_directions_extended:
    168
    168 168 168 168
    140 140 140 140
    140 140 140 140
    116 116 116 116
    116 116 116 116
    88 88 88 88
    88

used_ball_directions:
    168
    140
    116
    88
    @(byte (+ 128 168))
    @(byte (+ 128 140))
    @(byte (+ 128 116))
    @(byte (+ 128 88))

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


n:  jsr determine_reflection_sound
    jmp play_reflection_sound

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
    sta reflections_since_last_vaus_hit

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
    jsr reflect
    lda has_collision
    bne +n
    jsr check_hit_with_obstacle
    jsr avoid_endless_flight
    jmp move_ball

n:  lda has_hit_brick
    beq hit_solid

    lda #0
    sta reflections_since_last_vaus_hit

    lda has_removed_brick
    beq do_apply_reflection

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
    jsr determine_reflection_sound
    jsr play_reflection_sound

move_ball:
    jsr ball_step

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


play_reflection_sound:
    lda has_hit_brick
    ora has_hit_golden_brick
    ora has_hit_vaus
    beq +r
    lda snd_reflection
    beq +r
    ldy #0
    sty snd_reflection
    jmp play_sound
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
    sta reflections_since_last_vaus_hit
    jsr reflect_ball_obstacle
    jsr apply_reflection
    jsr remove_obstacle
    jmp increase_ball_speed

n:  dey
    bpl -l
    rts


determine_reflection_sound:
    ; Determine reflection sound.
    lda has_hit_brick
    ora has_hit_vaus
    beq +r
    lda snd_reflection
    bne +n
    lda sfx_reflection
    and #1
    clc
    adc #snd_reflection_low
    sta snd_reflection
n:  inc sfx_reflection
r:  rts

avoid_endless_flight:
    lda reflections_since_last_vaus_hit
    cmp #32
    bcc +r
    lda #0
    sta reflections_since_last_vaus_hit
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

n:  lda #255
    sta caught_ball
    lda #snd_reflection_low
    jsr play_sound
    lda #0
    sta sfx_reflection
    rts
