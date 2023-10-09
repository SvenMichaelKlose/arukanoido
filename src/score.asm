init_score:
    0
    clrmb <score1 >score1 num_score_digits
    clrmb <score2 >score2 num_score_digits
    clrmb <score_silver >score_silver num_score_digits
    0

    ldx #@(-- num_score_digits)
l:  lda score_20000,x
    sta next_powerup_score,x
    dex
    bpl -l
    rts

switch_player_score:
    lda has_two_players
    beq +l
    ldy active_player
    dey
    bne +n
l:  lda #<score1
    sta score
    lda #>score1
    sta @(++ score)
    rts
n:  lda #<score2
    sta score
    lda #>score2
    sta @(++ score)
    rts

init_hiscore:
    ldx #@(-- num_score_digits)
l:  lda score_50000,x
    sta hiscore,x
    dex
    bpl -l
    rts


; s: Score to add.
add_to_score:
    txa
    pha

    ldx active_player
    dex
    inc needs_redrawing_score1,x

    lda score
    sta d
    lda @(++ score)
    sta @(++ d)
    ldy #@(-- num_score_digits)
    jsr bcd_add

    ; Compare score with hiscore.
    lda score
    sta s
    lda @(++ score)
    sta @(++ s)
    lda #<hiscore
    sta d
    lda #>hiscore
    sta @(++ d)
    ldx #@(-- num_score_digits)
    jsr bcd_cmp
    bcc +n

    inc needs_redrawing_hiscore

    ; Copy score to highscore.
    lda #1
    sta has_hiscore
    ldy #@(-- num_score_digits)
l:  lda (score),y
    sta hiscore,y
    dey
    bpl -l

    ; Compare score with next powerup score.
n:  lda score
    sta s
    lda @(++ score)
    sta @(++ s)
    lda #<next_powerup_score
    sta d
    lda #>next_powerup_score
    sta @(++ d)
    ldx #@(-- num_score_digits)
    jsr bcd_cmp
    bcc +r

    jsr apply_bonus_p

    ;; Set next extra life score.
    lda num_lives_by_score
    bne +n
    ; Had one at 20.000, now for 40.000.
    lda #<score_40000
    sta s
    lda #>score_40000
    sta @(++ s)
    jmp +l
    ; Had one at 40.000, now after every 60.000.
n:  lda #<score_60000
    sta s
    lda #>score_60000
    sta @(++ s)
l:  lda #<next_powerup_score
    sta d
    lda #>next_powerup_score
    sta @(++ d)
    ldy #@(-- num_score_digits)
    jsr bcd_add
    inc num_lives_by_score

r:  pla
    tax
    rts

increase_silver_score:
    lda #<score_50
    sta s
    lda #>score_50
    sta @(++ s)
    lda #<score_silver
    sta d
    lda #>score_silver
    sta @(++ d)
    ldy #@(-- num_score_digits)
    jmp bcd_add
