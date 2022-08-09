blit_clear_char:
    ldy #7
    lda #0
l:  sta (d),y
    dey
    bpl -l
    rts
