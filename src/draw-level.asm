draw_level:
    ; Clear brick map.
    ldx #0
    txa
l:  sta bricks,x
    sta @(+ bricks 256),x
    dex
    bne -l

    lda #0
    sta bricks_left
    jsr fetch_brick
    sta scry

m:  lda #1
    sta scrx
l:  jsr scrcoladdr
    lda scr
    sta tmp
    lda @(++ scr)
    ora #>bricks
    sta @(++ tmp)
    jsr fetch_brick
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
    
fetch_brick:
    ldy #0
    lda (current_level),y
    ldx current_half
    bne +n
    lsr
    lsr
    lsr
    lsr
    inc current_half
    jmp +r
n:  and #$0f
    dec current_half
done:
    ldx #current_level

inc_zp:
    inc 0,x
    bne +r
    inc 1,x
r:  rts

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
    lda #bg_brick_special1
r:  rts

draw_walls:
    txa
    pha

    ; Draw top border without connectors.
    ldx #13
    lda #bg_top_1
l:  sta @(+ screen 30),x
    dex
    bne -l

    ; Draw top border connectors.
    lda #bg_top_2
    sta @(+ screen 30 3),x
    sta @(+ screen 30 10),x
    lda #bg_top_3
    sta @(+ screen 30 4),x
    sta @(+ screen 30 11),x

    ; Draw corners.
    lda #bg_corner_left
    sta @(+ screen 30)
    lda #bg_corner_right
    sta @(+ screen 30 14)
    
    ; Draw sides.
    lda #0
    sta scrx
    lda #3
    sta scry
a:  ldx #5
    lda #bg_side
l:  pha
    lda scry
    cmp #32
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
    jmp -a
done:
    pla
    pla
    tax
    rts
