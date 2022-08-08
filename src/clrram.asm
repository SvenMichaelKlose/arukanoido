clrram:
    ldx c
    inx
    inc @(++ c)
    ldy d
    lda #0
    sta d
    beq +n
l:  sta (d),y
    iny
    beq +m
n:  dex
    bne -l
    dec @(++ c)
    bne -l
    rts

m:  inc @(++ d)
    jmp -n
