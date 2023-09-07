draw_level:
    lda #<level_data
    ldy #>level_data
    jsr init_decruncher

    ; Decompress until current level.
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
    bne -l      ; (jmp)

n:  stx bricks_left

    ; Clear brick map.
    0
    clrmw <bricks >bricks $00 $02
    0

    ; Get starting row.
    jsr get_decrunched_byte
    sec
    adc playfield_yc
    sta scry

m:  lda #1
    sta scrx
l:  jsr scrcoladdr

    jsr scr2brick_in_d

    ; Get brick.
    jsr get_decrunched_byte
    tay     ; (Test on 0.)
    beq +o  ; No brick.
    cmp #15
    beq +r  ; End of level data.

    ; Plot brick.
    ldy scrx
    pha
    jsr brick_to_char
    sta (scr),y
    lda curcol
    sta (col),y
    pla

    ; Count number of bricks.
    cmp #b_golden
    beq +n
    inc bricks_left

    ; Store brick type in brick map.
n:  cmp #b_silver
    bne +n

    ; (One more hit for silver bricks every 8th level.)
    lda level
    lsr
    lsr
    lsr
    clc
    adc #@(++ b_silver)

n:  sta (d),y

    ; Step to next position.
o:  inc scrx
    lda scrx
    cmp #14
    bne -l
    inc scry
    bne -m      ; (jmp)

    ; Save lowest row index to guide obstacle movements.
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
    beq -a      ; (jmp)
done:
    pla
    pla
    tax
    rts

scr2brick_in_d:
    ; Make pointer into brick map.
    lda scr
    sta d
    lda @(++ scr)
    ora #>bricks
    sta @(++ d)
    rts
