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

ctrl_ball:
    lda caught_ball
    bpl +r

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
    cmp #@(- vaus_y 2)
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

    lda #@(- vaus_y 3)
    sta sprites_y,x

    lda #0
    sta reflections_since_last_vaus_hit

    lda mode
    cmp #mode_catching
    bne +n

    ; Catch ball.
    stx caught_ball
    lda #<ball_caught
    sta sprites_l,x
    lda #@(* 28 8)
    sta sprites_y,x
    jsr applied_reflection
    lda #snd_caught_ball
    jmp play_sound

n:  jmp applied_reflection

m:  jsr correct_trajectory
    jmp move_ball

no_vaus_hit:
    ; Reflect ball.
    lda #0
    sta side_degrees
    sta has_collision
    sta has_hit_brick

    jsr reflect
    lda has_collision
    beq -m
    lda has_hit_brick
    beq hit_solid

    lda #0
    sta reflections_since_last_vaus_hit

    ; Make bonus.
    lda mode
    cmp #mode_disruption    ; No bonuses in disruption mode.
    beq apply_reflection

    dec bricks_until_bonus
    bne apply_reflection
    lda #8
    sta bricks_until_bonus

    lda scrx
    asl
    asl
    asl
    sta @(+ bonus_init sprite_init_x)
    lda scry
    asl
    asl
    asl
    sta @(+ bonus_init sprite_init_y)
a:  jsr random
    and #%111
    cmp #%111
    beq -a      ; Only seven bonuses available.
    cmp current_bonus
    beq -a
    sta current_bonus
    pha
    asl
    asl
    asl
    clc
    adc #<bonus_l
    sta @(+ bonus_init sprite_init_gfx_l)
    pla
    sta @(+ bonus_init sprite_init_data)
    tay
    lda bonus_colors,y
    sta @(+ bonus_init sprite_init_color)
    ldy #@(- bonus_init sprite_inits)
    jsr add_sprite
    jmp apply_reflection

hit_solid:
    inc reflections_since_last_vaus_hit

apply_reflection:
    ; Calculate new direction.
    lda sprites_d,x     ; Get degrees.
    sec
    sbc side_degrees    ; Rotate back to zero degrees.
    jsr neg             ; Get opposite deviation from general direction.
    clc
    adc side_degrees    ; Rotate back to original axis.
    clc
    adc #128            ; Rotate to opposite direction.
    sta sprites_d,x

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
n:  rts

correct_trajectory:
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
    lda #70
    sta @(+ ball_init sprite_init_x)
    lda #@(* 28 8)
    sta @(+ ball_init sprite_init_y)
    lda #<ball_caught
    sta @(+ ball_init sprite_init_gfx_l)
    lda #default_ball_direction
    sta @(+ ball_init sprite_init_data)
    ldx #@(- num_sprites 3)
    stx caught_ball
    ldy #@(- ball_init sprite_inits)
    jmp replace_sprite

ball_accelerations_after_brick_hits:
    $00 $0a $0f $14 $1e $28 $37 $50 $6e $87 $a0 $b9 $d2 $e6 $f5 $ff ; TODO: Check if $ff really terminates.

adjust_ball_speed:
    txa
    pha
    ldx #0
l:  lda ball_accelerations_after_brick_hits,x
    cmp #$ff
    beq +n
    cmp num_brick_hits
    beq +l
    inx
    jmp -l
    
l:  lda ball_speed
    cmp #max_ball_speed
    bcs +n                  ; Already at maximum speed. Do nothing…
    inc ball_speed          ; Play the blues…
n:
    pla
    tax
    rts
