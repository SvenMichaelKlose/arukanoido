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
n:

    ; Un-extend Vaus.
    lda mode
    cmp #mode_extended
    bne +n
    txa
    pha
    jsr get_vaus_index_in_x
    lda #<gfx_vaus
    sta sprites_gl,x
    lda #>gfx_vaus
    sta sprites_gh,x
    lda #10
    sta sprites_dimensions,x
    lda sprites_x,x
    clc
    adc #4
    sta sprites_x,x
    lda #16
    sta vaus_width
    pla
    tax
n:

    lda #0
    sta mode

    ldy sprites_d,x
    lda @(-- bonus_funs_l),y
    sta @(+ +selfmod 1)
    lda @(-- bonus_funs_h),y
    sta @(+ +selfmod 2)
selfmod:
    jsr $1234
r:  dec has_bonus_on_screen
    jmp remove_sprite
    
m:  lda #1
    jmp sprite_down

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
    cmp #255
    bne +n
    jsr remove_bonuses  ; No slots left, last resort.
    jmp apply_bonus_e
n:  lda #mode_extended
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
    sta num_brick_hits
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
    lda #0
    sta (scr),y
    lda #white
    sta (col),y
    inc scry
    jsr scrcoladdr
    lda #0
    sta (scr),y
    lda #white
    sta (col),y
    inc scry
    jsr scrcoladdr
if @(eq *tv* :pal)
    lda #0
    sta (scr),y
    lda #white
    sta (col),y
    inc scry
    jsr scrcoladdr
    lda #@(+ bg_side 2)
    sta (scr),y
end
    rts

apply_bonus_d:
    jsr remove_bonuses

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
    sty tmp4
    lda sprites_d,y
    jsr turn_counterclockwise
    sta @(+ ball_init sprite_init_data)
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    ldy tmp4
    lda sprites_d,y
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

remove_bonuses:
    txa
    pha
    ldx #@(- num_sprites 2)
l:  lda sprites_i,x
    and #is_bonus
    beq +n
    jsr remove_sprite
n:  dex
    bpl -l
    pla
    tax
r:  rts

bonus_p_probabilities:
    $07 $df $3d $b9 $1b $5e

make_bonus_p:
    lda #bonus_p
    cpy #3
    bcc +ok
    lda #bonus_d
    jmp +ok

make_bonus:
    lda has_bonus_on_screen
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
    bne +n
    ldy mode_break
    beq +ok
    bne -a
n:  cmp #bonus_s        ; Bonus S is useless at minimum ball speed.
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

    ldy #@(- bonus_init sprite_inits)
    inc has_bonus_on_screen
    jmp add_sprite
