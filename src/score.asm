init_score:
    0
    c_setmb <score >score num_score_digits score_char0
    0
    rts

init_hiscore:
    0
    c_setmb <hiscore >hiscore num_score_digits score_char0
    0
    rts

; Y: Index into 'scores'.
add_to_score:
    inc has_new_score
    txa
    pha
    tya
    pha

    ldx #@(-- num_score_digits)
    clc
l:  lda score,x
    adc @(-- scores),y
    cmp #@(+ score_char0 10)
    bcc +n
    cpx #@(- num_score_digits 4)
    bne +j
    pha
    txa
    pha
    jsr apply_bonus_p
    pla
    tax
    pla
j:  sec
    sbc #10
n:  sta score,x
    dey
    dex
    bpl -l

    ; Compare score with hiscore.
    inx
    ldy #@(-- num_score_digits)
loop:
    lda score,x
    cmp hiscore,x
    beq +next
    bcc +done

    ; Copy score to highscore.
new_hiscore:
    lda #1
    sta has_hiscore
    ldx #@(-- num_score_digits)
l:  lda score,x
    sta hiscore,x
    dex
    bpl -l

next:
    inx
    dey
    bpl -loop

done:
    pla
    tay
    pla
    tax
    rts
