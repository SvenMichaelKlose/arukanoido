clrram:
    lda #0
setram:
    ldx cl
    inc ch
    ldy dl
    pha
    lda #0
    sta dl
    pla
l:  sta (d),y
    iny
    beq +n
m:  dex
    bne -l
    dec ch
    bne -l
    rts
n:  inc dh
    bne -m ; (jmp)
