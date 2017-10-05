draw_bitmap_width:      0
draw_bitmap_height:     0
draw_bitmap_num_chars:  0
draw_bitmap_y:          0

; A: Low address
; Y: High address
draw_bitmap:
    jsr init_decruncher

    jsr get_decrunched_byte
    sta draw_bitmap_width
    jsr get_decrunched_byte
    sta draw_bitmap_height

    lda scry
    sta draw_bitmap_y

l2: lda draw_bitmap_y
    sta scry
    lda draw_bitmap_height
    sta tmp2
l:  jsr scrcoladdr
    lda curcol
    sta (col),y
    lda curchar
    sta (scr),y
    jsr get_char_addr
    ldx #8
    ldy #0
l3: jsr get_decrunched_byte
    sta (d),y
    iny
    dex
    bne -l3
    inc curchar
    inc scry
    dec tmp2
    bne -l
    inc scrx
    dec draw_bitmap_width
    bne -l2

    rts
