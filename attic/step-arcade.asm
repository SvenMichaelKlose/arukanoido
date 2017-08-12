step_arcade:
    stx tmp
    lda sprites_d,x
    lsr
    lsr
    lsr
    lsr
    lsr
    tay
    lda dirjumps,y
    sta @(++ +idir)
    lda sprites_x,x
    ldy sprites_y,x
    tax
    lda framecounter
    clc
idir:
    bcc -idir

d0: and #%11
    bne +n
    inx
n:  iny
    jmp +done

d1: lsr
    bcs +n
    inx
n:  iny
    jmp +done

d2: lsr
    bcs +n
    inx
n:  dey
    jmp +done

d3: and #%11
    bne +n
    inx
n:  dey
    jmp +done

d4: and #%11
    bne +n
    dex
n:  dey
    jmp +done

d5: lsr
    bcs +n
    dex
n:  dey
    jmp +done

d6: lsr
    bcs +n
    dex
n:  iny
    jmp +done

d7: and #%11
    bne +n
    dex
n:  iny
    jmp +done


done:
    txa
    ldx tmp
    sta sprites_x,x
    sty sprites_y,x
    rts

dirjumps:
    @(- d0 idir 2)
    @(- d1 idir 2)
    @(- d2 idir 2)
    @(- d3 idir 2)
    @(- d4 idir 2)
    @(- d5 idir 2)
    @(- d6 idir 2)
    @(- d7 idir 2)
