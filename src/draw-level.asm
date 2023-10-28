init_foreground:
    ; Decrunch graphics to charset.
    lda #@(low (+ charset (* bg_start 8)))
    sta dl
    lda #@(high (+ charset (* bg_start 8)))
    sta dh
    0
    lday <gfx_background >gfx_background
    call <decrunch_block >decrunch_block

    ; Init break mode gate.
    movmw @(low (+ charset (* bg_side 8))) @(high (+ charset (* bg_side 8)))
          @(low (+ charset (* bg_gate2 8))) @(high (+ charset (* bg_gate2 8)))
          @(* 5 8) 0
    movmw @(low (+ charset (* bg_side3 8))) @(high (+ charset (* bg_side3 8)))
          @(low (+ charset (* bg_gate0 8))) @(high (+ charset (* bg_gate0 8)))
          16 0
    0
    rts

get_level:
    ;; Clear brick map.
    lda #0
    sta dl
    sta cl
    lda #2
    sta ch
    lda bricks
    sta dh
    jsr clrram

    lda level
    cmp #doh_level
    beq +r2

    lda #<level_data
    ldy #>level_data
    jsr init_decruncher

    ;; Decompress until current level.
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
    bne -l  ; (jmp)

n:  ldx active_player
    lda #0
    sta @(-- bricks_left),x

    ;; Get starting row.
    jsr get_decrunched_byte
    ldy active_player
    sta @(-- level_starting_row),y
    sec
    adc playfield_yc
    sta scry

m:  lda #1
    sta scrx
l:  jsr scraddr

    jsr scr2brick_in_d

    ;; Get brick.
    jsr get_decrunched_byte
    cmp #0
    beq +o              ; No brick.
    cmp #15
    beq +r              ; End of level data.

    ;; Count number of bricks.
    cmp #b_golden
    beq +n
    ldx active_player
    inc @(-- bricks_left),x

    ;; Store brick type in brick map.
n:  cmp #b_silver
    bne +n
    ; One more hit for silver bricks every 8th level.
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

    ; Save lowest row index where obstacles start circling.
r:  ldy scry
    dey
    tya
    ldy active_player
    sta @(-- level_ending_row),y
r2: rts

draw_level:
    ldy active_player
    lda @(-- level_ending_row),y
    sec
    sbc @(-- level_starting_row),y
    sta tmp
    inc tmp

    lda @(-- level_starting_row),y
    sec
    adc playfield_yc
    sta scry

m:  lda #1
    sta scrx
l:  jsr scrcoladdr
    jsr scr2brick_in_d

    ;; Plot brick.
    lda (d),y
    jsr brick_to_char
    sta (scr),y
    lda curcol
    sta (col),y

    ; Step to next position.
    inc scrx
    lda scrx
    cmp #14
    bne -l
    inc scry
    dec tmp
    bne -m      ; (jmp)
    rts

scr2brick_in_d:
    ; Make pointer into brick map.
    lda scr
    sta dl
    lda @(++ scr)
    ora bricks
    sta dh
    rts

brick_to_char:
    cmp #b_silver
    bcc +n
    lda #b_silver
n:  tax
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
    inc scrx
    lda #bg_top_3
    jsr plot_char
    lda #10
    sta scrx
    lda #bg_top_2
    jsr plot_char
    inc scrx
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
    clc
    adc #1
    inc scry
    dex
    bne -l
    beq -a      ; (jmp)
done:
    pla

    ; Draw gate.
    lda #14
    sta scrx
    lda playfield_yc
    clc
    adc #24
    sta scry
    lda #bg_gate0
    jsr plot_char
    inc scry
    lda #bg_gate1
    jsr plot_char
    inc scry
    lda #bg_gate2
    jsr plot_char
    inc scry
    lda #bg_gate3
    jsr plot_char
    inc scry
    lda #bg_gate4
    jsr plot_char
    inc scry
    lda #bg_gate5
    jsr plot_char

    pla
    tax
    rts

addr_gate0 = @(+ charset (* bg_gate0 8))
addr_gate3 = @(+ charset (* bg_gate3 8))

open_gate:
    ;; Move up upper part.
    ldy #0
    ldx #23
l:  lda @(+ addr_gate0 5),y
    sta @(+ addr_gate0 4),y
    iny
    dex
    bne -l

    ; Move down lower part.
    ldy #19
l:  lda @(+ addr_gate3 4),y
    sta @(+ addr_gate3 5),y
    dey
    bpl -l

    ; Clear middle ends.
    stx @(+ addr_gate3 3)
    stx @(+ addr_gate3 4)
    rts
