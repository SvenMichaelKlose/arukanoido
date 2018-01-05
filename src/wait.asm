wait:
    lda framecounter
l:  pha
    txa
    pha
    jsr exm_work
    pla
    tax
    pla
    cmp framecounter
    beq -l
    dex
    bne wait
    rts
