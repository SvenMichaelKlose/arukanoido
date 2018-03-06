blit_char:
    ldy #7
l1: lda (s),y
    sta (d),y
    dey
    bpl -l1
    rts

blit_clear_char:
    ldy #7
    lda #0
l:  sta (d),y
    dey
    bpl -l
    rts
