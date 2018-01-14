bonus_l = 1
bonus_e = 2
bonus_c = 3
bonus_s = 4
bonus_b = 5
bonus_d = 6
bonus_p = 7

bonus_colors:
    @(+ multicolor yellow)
    @(+ multicolor blue)
    @(+ multicolor green)
    @(+ multicolor yellow)
    @(+ multicolor purple)
    @(+ multicolor cyan)
    @(+ multicolor white)

ctrl_bonus:
    lda sprites_y,x
    cmp screen_height
    beq +r              ; Bonus left playfield…
    jsr find_hit
    bcs +m              ; Nothing hit…

    lda sprites_i,y
    and #is_vaus
    beq +m              ; Didn't hit the Vaus…

    lda sprites_d,x
    sta current_bonus

    lda #<score_1000
    sta s
    lda #>score_1000
    sta @(++ s)
    jsr add_to_score

    ; Release caught ball.
    lda caught_ball
    bmi +n
    jsr release_ball

    ; Restore default Vaus graphics.
n:  jsr get_vaus_index_in_y
    lda #<gfx_vaus
    sta sprites_gl,y
    lda #>gfx_vaus
    sta sprites_gh,y

    ; Un-extend Vaus.
    lda mode
    cmp #mode_extended
    bne +n
    lda #10
    sta sprites_dimensions,y
    lda sprites_x,y
    clc
    adc #4
    sta sprites_x,y
    lda #16
    sta vaus_width

n:  lda #0
    sta mode

    ldy sprites_d,x
    lda @(-- bonus_funs_l),y
    sta d
    lda @(-- bonus_funs_h),y
    sta @(++ d)
    jsr +j
r:  dec has_bonus_on_screen
    jmp remove_sprite
    
m:  lda #1
    jmp sprite_down
j:  jmp (d)

bonus_funs_l:
    <apply_bonus_l
    <apply_bonus_e
    <apply_bonus_c
    <apply_bonus_s
    <apply_bonus_b
    <apply_bonus_d
    <apply_bonus_p

bonus_funs_h:
    >apply_bonus_l
    >apply_bonus_e
    >apply_bonus_c
    >apply_bonus_s
    >apply_bonus_b
    >apply_bonus_d
    >apply_bonus_p

apply_bonus_l:
    lda #mode_laser
    sta mode
    rts

apply_bonus_e:
    jsr get_vaus_index_in_y
    lda sprites_x,y
    sec
    sbc #4
    sta sprites_x,y
    lda #<gfx_vaus_extended
    sta sprites_gl,y
    lda #>gfx_vaus_extended
    sta sprites_gh,y
    lda #11
    sta sprites_dimensions,y
    lda #mode_extended
    sta mode
    lda #24
    sta vaus_width
    lda #snd_growing_vaus
    jmp play_sound

apply_bonus_c:
    lda #mode_catching
    sta mode
    rts

apply_bonus_s:
    lda #min_ball_speed
    sta ball_speed
    lda #0              ; Time acceleration back to default.
    sta num_hits
    rts

apply_bonus_b:
    dec mode_break
    lda #14
    sta scrx
    lda #27
    sta scry
    jsr scrcoladdr
    lda #bg_side
    sta (scr),y

    inc scry
    jsr scrcoladdr
    lda #white
    sta (col),y
    inc scry
    jsr scrcoladdr
    lda #white
    sta (col),y

    lda is_landscape
    bne +n

    inc scry
    jsr scrcoladdr
    lda #white
    sta (col),y

    inc scry
    jsr scrcoladdr
    lda #@(+ bg_side 2)
    sta (scr),y

n:  rts

apply_bonus_d:
    lda #@(+ is_bonus is_laser)
    jsr remove_sprites_by_type

    ; Find ball.
    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and #is_ball
    bne +f
    dey
    bpl -l

    ; Add two new balls with +/- 45° change in direction.
f:  lda sprites_x,y                     ; Copy coordinates of current ball.
    sta @(+ ball_init sprite_init_x)
    lda sprites_y,y
    sta @(+ ball_init sprite_init_y)
    lda sprites_d,y
    sta tmp4
    jsr turn_counterclockwise
    sta @(+ ball_init sprite_init_data)
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    lda tmp4
    jsr turn_clockwise
    sta @(+ ball_init sprite_init_data)
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite

    ; Finish up so the rest of the game knows.
    inc balls
    inc balls
    lda #mode_disruption
    sta mode
    rts

apply_bonus_p:
    lda #snd_bonus_life
    jsr play_sound
    inc lifes
    jmp draw_lifes

rotate_bonus:
    sta s
    stx @(++ s)
    ldy #6
    lda (s),y
    pha
    dey
l:  lda (s),y
    iny
    sta (s),y
    dey
    dey
    bne -l
    pla
    iny
    sta (s),y
r:  rts

rotate_bonuses:
    lda framecounter
    lsr
    bcc -r
    lsr
    bcc +n
    lsr
    bcc +m
    lda #<gfx_bonus_l
    ldx #>gfx_bonus_l
    jsr rotate_bonus
    lda #<gfx_bonus_e
    ldx #>gfx_bonus_e
    jmp rotate_bonus
m:  lda #<gfx_bonus_c
    ldx #>gfx_bonus_c
    jsr rotate_bonus
    lda #<gfx_bonus_s
    ldx #>gfx_bonus_s
    jmp rotate_bonus
n:  lsr
    bcc +m
    lda #<gfx_bonus_b
    ldx #>gfx_bonus_b
    jsr rotate_bonus
    lda #<gfx_bonus_d
    ldx #>gfx_bonus_d
    jmp rotate_bonus
m:  lda #<gfx_bonus_p
    ldx #>gfx_bonus_p
    jmp rotate_bonus

bonus_p_probabilities:
    $07 $df $3d $b9 $1b $5e

make_bonus_p:
    lda #bonus_p
    cpy #3
    bcc +ok
    ldy mode_break
    bne +ok
    lda #bonus_b
    jmp +ok

make_bonus:
    lda removed_bricks
    cmp #1
    beq +o
    cmp #4
    beq +o
    and #7
    bne -r

o:  lda has_bonus_on_screen
    ora has_hit_silver_brick
    bne -r

a:  jsr random

    ; Check for bonus P.
    ldy #5
l:  cmp bonus_p_probabilities,y
    beq make_bonus_p
    dey
    bpl -l

    and #7
    bne +n
    lda #bonus_e
n:  cmp current_bonus
    beq -a              ; Bonus already active…
    cmp #bonus_b
    beq -a
    cmp #bonus_p
    beq -a
n:  cmp #bonus_s
    bne +ok
    ldy ball_speed
    cpy #min_ball_speed
    beq -a

ok: sta @(+ bonus_init sprite_init_data)
    sec
    sbc #1
    tay
    asl
    asl
    asl
    clc
    adc #<gfx_bonus_l
    sta @(+ bonus_init sprite_init_gfx_l)
    lda bonus_colors,y
    sta @(+ bonus_init sprite_init_color)

    lda removed_brick_x
    asl
    asl
    asl
    sta @(+ bonus_init sprite_init_x)
    lda removed_brick_y
    asl
    asl
    asl
    sta @(+ bonus_init sprite_init_y)

    ldy #@(- bonus_init sprite_inits)
    inc has_bonus_on_screen
    jmp add_sprite
