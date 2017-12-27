wait:
    lda framecounter
l:  cmp framecounter
    beq -l
    dex
    bne wait
    rts
