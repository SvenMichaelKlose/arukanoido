clrram:
    ldx cl
    inx
    inc ch
    ldy dl
    lda #0
    sta dl
l:  dex
    beq +m
    sta (d),y
    iny
    bne -l
    inc dh
    bne -l ; (jmp)
m:  dec ch
    bne -l
    rts
