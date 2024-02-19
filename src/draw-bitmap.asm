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

l:  ; Copy into temporary buffer.
    ldx #8
    ldy #0
l3: jsr get_decrunched_byte
    sta scratch,y
    iny
    dex
    bne -l3

    ; Check if char is empty.
    txa
    ldx #7
l4: ora scratch,x
    bne +l5
    dex
    bpl -l4
    bmi +skip

    ;; Draw char.
l5: ;jsr scrcoladdr
    ldy scry
    lda line_addresses_l,y
    sta scr
    sta col
    lda line_addresses_h,y
    sta @(++ scr)
    ora #>colors
    sta @(++ col)
    ldy scrx

    ; Set char colour.
    lda curcol
    sta (col),y

    ; Allocate char.
    lda curchar
    inc curchar
    sta (scr),y

    ; Copy into charset.
    jsr get_char_addr
    ldy #7
l3: lda scratch,y
    sta (d),y
    dey
    bpl -l3

skip:
    inc scry
    dec tmp2
    bne -l

    inc scrx
    dec draw_bitmap_width
    bne -l2

    rts
