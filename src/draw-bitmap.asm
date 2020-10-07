; Draw exomized bitmap.

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

    ; Draw column
l2: lda draw_bitmap_y
    sta scry
    lda draw_bitmap_height
    sta tmp2

    ; Draw char.
l:  jsr scrcoladdr

    ; Set char colour.
    lda curcol
    sta (col),y

    ; Allocate char.
    lda curchar
    inc curchar
    sta (scr),y

    ; Copy into charset.
    jsr get_char_addr
    ldx #8
    ldy #0
l3: jsr get_decrunched_byte
    sta (d),y
    iny
    dex
    bne -l3

    inc scry
    dec tmp2
    bne -l

    inc scrx
    dec draw_bitmap_width
    bne -l2

    rts
