clrram:
    lda #0
setram:
    ldx cl
    inx
    inc ch
    ldy dl
    pha
    lda #0
    sta dl
    pla
    jmp +m
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
