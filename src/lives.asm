draw_lives:
    lda is_landscape
    bne draw_lives_landscape

draw_lives_portrait:
    txa
    pha
    ldx lifes
    dex
    cpx #13
    bcs +n
    lda #0
    sta lifes_on_screen,x
l:  cpx #14
    bcs +n
    cpx #0
    beq +done
    lda #bg_minivaus
    sta @(-- lifes_on_screen),x
    lda #@(+ multicolor white)
    sta @(-- lifes_on_colors),x
n:  dex
    jmp -l
done:
    pla
    tax
    rts

draw_lives_landscape:
    txa
    pha
    lda #16
    sta scrx
    lda yc_max
    sta scry
    lda #bg_minivaus
    sta curchar
    lda #@(+ multicolor white)
    sta curcol
    ldx lifes
    dex
    beq +done
l:  jsr plot_life
    dex
    bne -l
done:
    lda #0
    sta curchar
    jsr plot_scr
    pla
    tax
    rts

plot_life:
    jsr plot_scr
    inc scrx
    lda scrx
    cmp xc_max
    bne +r
    lda #16
    sta scrx
    dec scry
r:  rts
