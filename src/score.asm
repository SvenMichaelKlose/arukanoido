init_score:
    0
    c_setmb <score >score num_score_digits 0
    0
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
    bcc +r

    ; Copy score to highscore.
    lda #1
    sta has_hiscore
    ldy #@(-- num_score_digits)
l:  lda score,y
    sta hiscore,y
    dey
    bpl -l

r:  ldx tmp
    rts
