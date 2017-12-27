moveram:
    ldy #0
    ldx c
    sty c
    inc @(++ c)
    cmp #0
    bne copy_backwards

copy_forwards:
l:  lda (s),y
    sta (d),y
    iny
    beq +k
q:  dex
    bne -l
    dec @(++ c)
    bne -l
    rts

k:  inc @(++ s)
    inc @(++ d)
    jmp -q

copy_backwards:
l2: lda (s),y
    sta (d),y
    dey
    cpy #$ff
    beq +m2
q2: dex
    bne -l2
    dec @(++ c)
    bne -l2
    rts

m2: dec @(++ s)
    dec @(++ d)
    jmp -q2
