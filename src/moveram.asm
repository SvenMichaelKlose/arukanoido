moveram:
    ldy #0
    ldx c
    inx
    inc ch
    bne +n
l:  lda (s),y
    sta (d),y
    iny
    beq +m
n:  dex
    bne -l
    dec ch
    bne -l
    rts
m:  inc sh
    inc dh
    bne -n ; (jmp)
