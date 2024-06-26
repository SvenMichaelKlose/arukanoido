; d: Destination
; A: char
print4x8:
    stx p_x
    sty p_y

    ldy #0
    sty tmp2
    asl
    rol tmp2
    asl
    rol tmp2
    asl
    rol tmp2
    clc
    adc #<charset4x8
    sta tmp
    lda tmp2
    adc #>charset4x8
    sta tmp2

    ldy #0
    lda scrx2
    lsr
    bcs +l

    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    iny
    lda (tmp),y
    and #$f0
    sta (d),y
    jmp +r

l:  lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y
    iny
    lda (tmp),y
    and #$0f
    ora (d),y
    sta (d),y

r:  ldx p_x
    ldy p_y
    rts

print4x8_dynalloc:
    pha

    ; Line position to screen-X.
    lda scrx2
    lsr
    sta scrx

    ; Plot char.
    ldy scrx
    lda curchar
    sta (scr),y
    lda curcol
    sta (col),y

    pla
    jsr print4x8

    ; Step to next char if required.
    lda scrx2
    lsr
    bcc +r
    inc curchar
    lda dl
    clc
    adc #8
    sta dl
    bcc +r
    inc dh

r:  inc scrx2
    rts

print_string_ay:
    sta sl
    sty sh

; X: Number of chars
; scrx2/scry: Text position
; curchar: Character to print into.
print_string:
    jsr scrcoladdr
    jsr get_curchar_addr
    ldy #0
l:  tya
    pha
    lda (s),y
    bmi +r
    jsr print4x8_dynalloc
    pla
    tay
    iny
    jmp -l
r:  pla
    inc curchar
    rts
