clrram:
    ldx cl
    ldy dl
    lda #0
    sta dl
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
