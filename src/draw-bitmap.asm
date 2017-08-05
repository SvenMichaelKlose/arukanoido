draw_bitmap_width:      0
draw_bitmap_height:     0
draw_bitmap_num_chars:  0
draw_bitmap_y:          0

; A: Low address
; Y: High address
draw_bitmap:
    sta s
    sty @(++ s)

    ldy #0
    lda (s),y
    sta draw_bitmap_width
    tax
    inc s
    lda (s),y
    sta draw_bitmap_height
    inc s

    lda scry
    sta draw_bitmap_y

l2: lda draw_bitmap_y
    sta scry
    ldx draw_bitmap_height
l:  jsr scrcoladdr
    lda curcol
    sta (col),y
    lda curchar
    sta (scr),y
    jsr get_char_addr
    jsr blit_char
    lda s
    clc
    adc #8
    sta s
    bcc +n
    inc @(++ s)
n:  inc curchar
    inc scry
    dex
    bne -l
    inc scrx
    dec draw_bitmap_width
    bne -l2

    rts
