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
    sta dl
    lda @(++ score)
    sta dh
    ldy #@(-- num_score_digits)
    jsr bcd_add

    ; Compare score with hiscore.
    lda score
    sta sl
    lda @(++ score)
    sta sh
    lda #<hiscore
    sta dl
    lda #>hiscore
    sta dh
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
    sta sl
    lda @(++ score)
    sta sh
    lda #<next_powerup_score
    sta dl
    lda #>next_powerup_score
    sta dh
    ldx #@(-- num_score_digits)
    jsr bcd_cmp
    bcc +r

    jsr apply_bonus_p

    ;; Set next extra life score.
    lda num_lives_by_score
    bne +n
    ; Had one at 20.000, now for 40.000.
    lda #<score_40000
    sta sl
    lda #>score_40000
    sta sh
    bne +l ; (jmp)
    ; Had one at 40.000, now after every 60.000.
n:  lda #<score_60000
    sta sl
    lda #>score_60000
    sta sh
l:  lda #<next_powerup_score
    sta dl
    lda #>next_powerup_score
    sta dh
    ldy #@(-- num_score_digits)
    jsr bcd_add
    inc num_lives_by_score

r:  pla
    tax
    rts

init_silver_score:
    0
    clrmb <score_silver >score_silver num_score_digits
    0
    ldx level
l:  lda #<score_50
    sta sl
    lda #>score_50
    sta sh
    lda #<score_silver
    sta dl
    lda #>score_silver
    sta dh
    ldy #@(-- num_score_digits)
    txa
    pha
    jsr bcd_add
    pla
    tax
    dex
    bne -l
    rts
