draw_level:
    lda #<level_data
    ldy #>level_data
    jsr init_decruncher

    ldx level
l:  dex
    beq +n
    txa
    pha
m:  jsr get_decrunched_byte
    cmp #15
    bne -m
    pla
    tax
    jmp -l

    ; Clear brick map.
n:  ldx #0
    txa
l:  sta bricks,x
    sta @(+ bricks 256),x
    dex
    bne -l

    lda #0
    sta bricks_left
    jsr get_decrunched_byte
    sec
    adc playfield_yc
    sta scry

m:  lda #1
    sta scrx
l:  jsr scrcoladdr
    lda scr
    sta tmp
    lda @(++ scr)
    ora #>bricks
    sta @(++ tmp)
    jsr get_decrunched_byte
    cmp #0
    beq +o
    cmp #15
    beq +r
    ldy scrx
    pha
    jsr brick_to_char
    sta (scr),y
    lda curcol
    sta (col),y
    pla
    cmp #b_golden
    beq +n
    inc bricks_left
n:  cmp #b_silver
    bne +n
    lda level
    lsr
    lsr
    lsr
    clc
    adc #@(++ b_silver)
n:  sta (tmp),y
o:  inc scrx
    lda scrx
    cmp #14
    bne -l
    inc scry
    jmp -m
    
r:  ldy scry
    dey
    sty level_bottom_y
    rts

brick_to_char:
    tax
    lda @(-- brick_colors),x
    sta curcol
    txa
    beq +r
    lda #bg_brick_orange
    cpx #b_orange
    beq +r
    lda #bg_brick
    cpx #b_golden
    bcc +r
    lda #bg_brick_special
r:  rts

draw_walls:
    txa
    pha

    lda playfield_yc
    sta scry
    lda #@(+ multicolor white)
    sta curcol

    ; Draw top border without connectors.
    lda #1
    sta scrx
l:  lda #bg_top_1
    jsr plot_char
    inc scrx
    lda scrx
    cmp #14
    bne -l

    ; Draw top border connectors.
    lda #3
    sta scrx
    lda #bg_top_2
    jsr plot_char
    lda #10
    sta scrx
    lda #bg_top_2
    jsr plot_char

    lda playfield_yc
    sta scry
    lda #4
    sta scrx
    lda #bg_top_3
    jsr plot_char
    lda #11
    sta scrx
    lda #bg_top_3
    jsr plot_char

    ; Draw corners.
    lda #0
    sta scrx
    lda #bg_corner_left
    jsr plot_char
    lda #14
    sta scrx
    lda #bg_corner_right
    jsr plot_char
    
    ; Draw sides.
    lda #0
    sta scrx
    lda playfield_yc
    clc
    adc #1
    sta scry
a:  ldx #5
    lda #bg_side
l:  pha
    lda scry
    cmp screen_rows
    beq +done
    jsr scrcoladdr
    pla
    sta (scr),y
    ldy #14
    sta (scr),y
    pha
    lda #@(+ multicolor white)
    ldy #14
    sta (col),y
    pla
    clc
    adc #1
    inc scry
    dex
    bne -l
    jmp -a
done:
    pla
    pla
    tax
    rts
