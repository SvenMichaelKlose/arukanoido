lifes_on_screen = @(+ (* 31 screen_columns) 1 screen)
lifes_on_colors = @(+ (* 31 screen_columns) 1 colors)

if @(eq *tv* :pal)
draw_lifes:
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
end

if @(eq *tv* :ntsc)
draw_lifes:
    txa
    pha
    lda #16
    sta scrx
    lda #@(-- screen_rows)
    sta scry
    lda #bg_minivaus
    sta curchar
    lda #@(+ multicolor white)
    sta curcol
    ldx lifes
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
    cmp #@(-- screen_columns)
    bne +r
    lda #16
    sta scrx
    dec scry
r:  rts
end
