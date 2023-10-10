moveram:
    ldy #0
    ldx c
    inc ch
    cmp #0
    bne copy_backwards

copy_forwards:
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

copy_backwards:
l:  lda (s),y
    sta (d),y
    dey
    cpy #$ff
    beq +m
n:  dex
    bne -l
    dec ch
    bne -l
    rts
m:  dec sh
    dec dh
    jmp -n
