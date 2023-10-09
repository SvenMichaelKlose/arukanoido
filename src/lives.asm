draw_lives:
    lda is_landscape
    bne draw_lives_landscape

draw_lives_portrait:
    ldy active_player
    ldx @(-- lives1),y
    dex
    cpx #9
    bcs +n
    lda #0
    sta lives_on_screen,x
l:  cpx #9
    bcs +n
    cpx #0
    beq +done
    lda #bg_minivaus
    sta @(-- lives_on_screen),x
    lda #@(+ multicolor white)
    sta @(-- lives_on_colors),x
n:  dex
    jmp -l
done:
    rts

draw_lives_landscape:
    lda #16
    sta scrx
    lda yc_max
    sta scry
    lda #bg_minivaus
    sta curchar
    lda #@(+ multicolor white)
    sta curcol
    ldy active_player
    ldx @(-- lives1),y
    dex
    beq +done
l:  jsr plot_life
    dex
    bne -l
done:
    lda #0
    sta curchar
    jsr plot_scr
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
