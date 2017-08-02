init_score:
    0
    c_setmb <score >score num_score_digits 0
    c_setmb <score_silver >score_silver num_score_digits 0
    0
    ldx #@(-- num_score_digits)
l:  lda score_20000,x
    sta next_powerup_score,x
    dex
    bpl -l
    rts

init_hiscore:
    0
    c_setmb <hiscore >hiscore num_score_digits 0
    0
    rts

; s: Score to add.
add_to_score:
    stx tmp
    inc has_new_score

    lda #<score
    sta d
    lda #>score
    sta @(++ d)
    ldy #@(-- num_score_digits)
    jsr bcd_add

    ; Compare score with hiscore.
    lda #<score
    sta s
    lda #>score
    sta @(++ s)
    lda #<hiscore
    sta d
    lda #>hiscore
    sta @(++ d)
    ldx #@(-- num_score_digits)
    jsr bcd_cmp
    bcc +n

    ; Copy score to highscore.
    lda #1
    sta has_hiscore
    ldy #@(-- num_score_digits)
l:  lda score,y
    sta hiscore,y
    dey
    bpl -l

n:

    ; Compare score with next powerup score.
    lda #<score
    sta s
    lda #>score
    sta @(++ s)
    lda #<next_powerup_score
    sta d
    lda #>next_powerup_score
    sta @(++ d)
    ldx #@(-- num_score_digits)
    jsr bcd_cmp
    bcc +n
    bne +n

stop:
    inc lifes

    ; Add 50.000pts to new powerup score.
    lda #<score_50000
    sta s
    lda #>score_50000
    sta @(++ s)
    lda #<next_powerup_score
    sta d
    lda #>next_powerup_score
    sta @(++ d)
    ldy #@(-- num_score_digits)
    jsr bcd_add

n:  ldx tmp
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
