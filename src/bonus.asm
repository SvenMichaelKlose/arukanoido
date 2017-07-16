bonus_colors:
    @(+ multicolor yellow)
    @(+ multicolor blue)
    @(+ multicolor green)
    @(+ multicolor yellow)
    @(+ multicolor purple)
    @(+ multicolor cyan)
    @(+ multicolor white)

bonus_probabilities:    ; TODO: Use this.
    $07 $df $3d $b9 $1b $5e   ; S C E D L B – P ???

ctrl_bonus:
    lda sprites_y,x
    beq +r              ; Bonus left playfield…
    jsr find_hit
    bcs +m              ; Nothing hit…

    lda sprites_i,y
    and #is_vaus
    beq +m              ; Didn't hit the Vaus…

    ldy #@(- score_1000 scores)
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
    ldx #spriteidx_vaus
    lda #<vaus
    sta sprites_l,x
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
    lda bonus_funs_l,y
    sta @(+ +selfmod 1)
    lda bonus_funs_h,y
    sta @(+ +selfmod 2)
selfmod:
    jsr $1234
r:  jmp remove_sprite
    
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
    ldy #spriteidx_vaus
    lda sprites_x,y
    sec
    sbc #4
    sta sprites_x,y
    lda #<vaus_extended
    sta sprites_l,y
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
    inc mode_break
    lda #14
    sta scrx
    lda #28
    sta scry
l:  jsr scrcoladdr
    lda #0
    sta (scr),y
    inc scry
    lda scry
    cmp #31
    bne -l
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
    lda sprites_d,y
    sta @(+ ball_init sprite_init_data)
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
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
    lda #<bonus_l
    ldx #>bonus_l
    jsr rotate_bonus
    lda #<bonus_e
    ldx #>bonus_e
    jmp rotate_bonus
m:  lda #<bonus_c
    ldx #>bonus_c
    jsr rotate_bonus
    lda #<bonus_s
    ldx #>bonus_s
    jmp rotate_bonus
n:  lsr
    bcc +m
    lda #<bonus_b
    ldx #>bonus_b
    jsr rotate_bonus
    lda #<bonus_d
    ldx #>bonus_d
    jmp rotate_bonus
m:  lda #<bonus_p
    ldx #>bonus_p
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
    rts
