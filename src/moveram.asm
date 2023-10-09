moveram:
    ldy #0
    ldx c
    inx
    inc ch
    cmp #0
    bne copy_backwards

copy_forwards:
l:  dex
    beq +q
    lda (s),y
    sta (d),y
    iny
    bne -l
    inc sh
    inc dh
    bne -l ; (jmp)
q:  dec ch
    bne -l
    rts

copy_backwards:
l2: dex
    beq +q2
    lda (s),y
    sta (d),y
    dey
    cpy #$ff
    bne -l2
    dec sh
    dec dh
    jmp -l2
q2: dec ch
    bne -l2
    rts
