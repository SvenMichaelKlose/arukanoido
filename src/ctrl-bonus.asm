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

    lda #0
    sta removed_bricks_for_bonus
    sta has_missed_bonus
    sta bonus_is_dropping

    ;; Score 1000pts.
    lda #<score_1000
    sta sl
    lda #>score_1000
    sta sh
    jsr add_to_score

    ;; Release caught ball.
    lda caught_ball
    bmi +n              ; No ball caught…
    jsr release_ball
    ; Restore default Vaus graphics.
n:  ldy vaus_sprite_index
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
    sty active_bonus
    jsr remove_sprite
    lda @(-- bonus_funs_l),y
    sta dl
    lda @(-- bonus_funs_h),y
    sta dh
    jsr +j
    rts

m:  lda #1
    jmp sprite_down
j:  jmp (d)

r:  lda #0
    sta bonus_is_dropping
    jmp remove_sprite

bonus_funs_l:
    <apply_bonus_l <apply_bonus_e <apply_bonus_c <apply_bonus_s
    <apply_bonus_b <apply_bonus_d <apply_bonus_p

bonus_funs_h:
    >apply_bonus_l >apply_bonus_e >apply_bonus_c >apply_bonus_s
    >apply_bonus_b >apply_bonus_d >apply_bonus_p

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
    lda #mode_extended
    sta mode
    ldy vaus_sprite_index
    lda preshifted_vaus_extended
    sta sprites_pgl,y
    lda @(++ preshifted_vaus_extended)
    sta sprites_pgh,y
    lda #11
    sta sprites_dimensions,y
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
    lda #min_ball_speed
    sta ball_speed

    ;; Reset reason for speeding up.
    lda #0
    sta num_hits

    ;; Subtract speed by 2 (1 pixel per frame).
    ldy ball_speed
    dey
    dey
    cpy #min_ball_speed
    bcs +n
    beq +n
    ldy #min_ball_speed
n:  sty ball_speed
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
f:  lda sprites_x,y                     ; Copy coordinates of ball.
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
    txa
    pha
    ldx active_player
    inc @(-- lives1),x
    pla
    tax
    inc needs_redrawing_lives
    lda #snd_bonus_life
    jmp play_sound

;;; Rotate graphics of active bonus.
rotate_bonuses:
    lda bonus_is_dropping
    beq -r

    ;; Rotate every 8th frame.
    lda framecounter
    and #%111
    bne -r

    ;; Get char address.
    lda last_bonus
    asl
    asl
    asl
bonus_base = @(- gfx_bonus_l 8)
    clc
    adc #<bonus_base
    sta sl
    lda #>bonus_base
    adc #0
    sta sh

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
    ;asl hits_before_bonus
;    bne +l  ; (jmp)
n:  cmp #4
;    bne +l
;    asl hits_before_bonus
l:

if @*debug?*
    ;; Ensure selected bonus.
    lda next_bonus
    bne +ok
end

    ;; Roll the dice.
a:  jsr random
    and #7
    bne +n
    lda #bonus_e        ; 0 is the extended mode bonus.

    ;; Avoid making an already caught bonus.
n:  cmp active_bonus
    beq -a              ; Already active…
    cmp last_bonus
    beq -a              ; Just threw that one…
    ; Do extra check for break mode bonus as it's not
    ; denoted in 'mode' but 'mode_break'.
    cmp #bonus_b
    bne +n
    lda mode_break
    bne -a              ; Got it already…
    lda #bonus_b
    bne +m  ; (jmp)
    ; No slowing down if already at minimum ball speed.
n:  cmp #bonus_s
    bne +m
    ldy ball_speed
    cpy #min_ball_speed
    beq -a

    ;; Remember to avoid creating the same bonus twice.
m:  sta last_bonus

    ;; Init sprite.
    ; Store bonus type.
ok: sta @(+ bonus_init sprite_init_data)

    ; Get its graphics.
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

    lda #1
    sta bonus_is_dropping
    sta has_missed_bonus
    ldy #@(- bonus_init sprite_inits)
    jmp add_sprite
