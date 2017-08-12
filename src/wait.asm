wait:
l:  lda $9004
    lsr
    bne -l
n:  lda $9004
    lsr
    bne -n
    dex
    bne -l
    rts
