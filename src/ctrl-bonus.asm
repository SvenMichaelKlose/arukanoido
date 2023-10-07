bonus_l = 1 ; Laser
bonus_e = 2 ; Extended Vaus
bonus_c = 3 ; Catch ball
bonus_s = 4 ; Slow down
bonus_b = 5 ; Break mode
bonus_d = 6 ; Disruption mode
bonus_p = 7 ; Power up

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

    ;; Test on collision with the Vaus.
    lda #is_vaus
    jsr find_hit
    bcs +m              ; Nothing hit…

    lda sprites_d,x
    sta current_bonus

    lda #0
    sta removed_bricks_for_bonus
    sta has_missed_bonus

    ;; Score 1000pts.
    lda #<score_1000
    sta s
    lda #>score_1000
    sta @(++ s)
    jsr add_to_score

    ;; Release caught ball.
    lda caught_ball
    bmi +n              ; No ball caught…
    jsr release_ball
    ; Restore default Vaus graphics.
n:  ldy vaus_sprite_index
    lda #<gfx_vaus
    sta sprites_gl,y
    lda #>gfx_vaus
    sta sprites_gh,y
    lda preshifted_vaus
    sta sprites_pgl,y
    lda @(++ preshifted_vaus)
    sta sprites_pgh,y

    ;; Un-extend Vaus.
    lda mode
    cmp #mode_extended
    bne +n
    lda #10
    sta sprites_dimensions,y
    lda #16
    sta vaus_width
    jsr move_vaus_right
    jsr move_vaus_right

n:  lda #0
    sta mode

    ldy sprites_d,x
    jsr remove_sprite
    lda @(-- bonus_funs_l),y
    sta d
    lda @(-- bonus_funs_h),y
    sta @(++ d)
    jsr +j
r:  lda #0
    sta bonus_is_dropping
    rts
    
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

;;; Laser mode
apply_bonus_l:
    lda #mode_laser
    sta mode
    ldy vaus_sprite_index
    lda preshifted_vaus_laser
    sta sprites_pgl,y
    lda @(++ preshifted_vaus_laser)
    sta sprites_pgh,y
    rts

;;; Extension mode
apply_bonus_e:
    ldy vaus_sprite_index
    lda preshifted_vaus_extended
    sta sprites_pgl,y
    lda @(++ preshifted_vaus_extended)
    sta sprites_pgh,y
    lda #11
    sta sprites_dimensions,y
    lda #mode_extended
    sta mode
    lda #24
    sta vaus_width
    jsr move_vaus_left
    jsr move_vaus_left
    lda #snd_growing_vaus
    jmp play_sound

;;; Catching mode
apply_bonus_c:
    lda #mode_catching
    sta mode
    rts

;;; Slow down ball
apply_bonus_s:
    ;; Reset reason for speeding up.
    lda #0
    sta num_hits

    ;; Subtract speed by 2 (1 pixel per frame).
    ldy ball_speed
    dey
    dey
    cpy #min_ball_speed
    bcc +n
    sty ball_speed
    rts

    ; Mininum speed, never any slower.
n:  lda #min_ball_speed
    sta ball_speed
    rts

apply_bonus_b:
    dec mode_break
    rts

;;; Disruption mode (three balls)
apply_bonus_d:
    lda #mode_disruption
    sta mode

    ;; Remove laser or we'running out of sprites.
    lda #is_laser
    jsr remove_sprites_by_type

    ;; Find ball.
    ldy #@(-- num_sprites)
l:  lda sprites_i,y
    and #is_ball
    bne +f
    dey
    bpl -l

    ;; Add two new balls with +/- 45° change in direction.
f:  lda sprites_x,y                     ; Copy coordinates of current ball.
    sta @(+ ball_init sprite_init_x)
    lda sprites_y,y
    sta @(+ ball_init sprite_init_y)
    lda sprites_d,y
    pha
    jsr turn_counterclockwise
    sta @(+ ball_init sprite_init_data)
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    inc balls
    pla
    jsr turn_clockwise
    sta @(+ ball_init sprite_init_data)
    ldy #@(- ball_init sprite_inits)
    jsr add_sprite
    inc balls

r:  rts

;;; Extra life
apply_bonus_p:
    inc lives
    inc needs_redrawing_lives
    lda #snd_bonus_life
    jmp play_sound

;;; Rotate the current bonus graphics.  No fuzz.
rotate_bonuses:
    lda framecounter
    and #%111
    bne -r

    lda bonus_is_dropping
    beq -r

    ;; Get char address of current bonus.
    asl
    asl
    asl
bonus_base = @(- gfx_bonus_l 8)
    clc
    adc #<bonus_base
    sta s
    lda #>bonus_base
    adc #0
    sta @(++ s)

    ;; Rotate.
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

bonus_p_probabilities:
    $07 $df $3d $b9 $1b $5e

;;; Make power-up bonus.
make_bonus_p:
    lda #bonus_p
    cpy #3
    bcc +ok
    ldy mode_break
    bne +ok
    lda #bonus_b
    jmp +ok

;;; Make bonus (complicate arcade version)
make_bonus:
    ;; No bonus if one is already on the screen
    ;; or if a silver brick has been removed.
    lda bonus_is_dropping
    ora has_hit_silver_brick
    bne -r

    ;; Create right away if the last one was missed.
    lda has_missed_bonus
    bne +l

    ;; Check if we should make a bonus at all,
    ;; based on the number of removed bricks.
    lda removed_bricks_for_bonus
    cmp hits_before_bonus
    bne -r
    cmp #1
    bne +n
    asl hits_before_bonus
    asl hits_before_bonus
    bne +l  ; (jmp)
n:  cmp #4
    bne +l
    asl hits_before_bonus
l:

if @*debug?*
    ;; Ensure selected bonus.
    lda next_bonus
    bne +ok
end

    inc has_missed_bonus

    ;; Roll the dice.
a:  jsr random
    and #7
    bne +n
    lda #bonus_e        ; 0 is the extended mode bonus.

    ;; Avoid making an already caught bonus.
n:  cmp current_bonus
    beq -a              ; Already active…
    cmp last_bonus
    beq -a              ; Just had that one…

    ;; Do extra check for break mode bonus as it's not
    ;; denoted in 'mode' but 'mode_break'.
    cmp #bonus_b
    bne +n
    lda mode_break
    bne -a              ; Got it already…
    lda #bonus_b

    ;; Remember to avoid creating the same bonus twice.
n:  sta last_bonus

    ;; Init sprite.
ok: sta @(+ bonus_init sprite_init_data)
    sta bonus_is_dropping
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

    ; Move it to the position of the removed brick.
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
    jmp add_sprite
