; d: Destination
; A: char
; C: 0: left half, 1: right half
print4x8:
    sta print4x8_char
    stx p_x
    sty p_y
    php

    and #%11111110
    ldy #0
    sty tmp2
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

    lda print4x8_char
    and #1
    sta print4x8_char

    plp
    bcs +n

    ldy #7
l:  lda (tmp),y
    ldx print4x8_char
    bne +m
    asl
    asl
    asl
    asl
m:  and #$f0
    sta (d),y
    dey
    bpl -l
    bmi +r

n:  ldy #7
l:  lda (tmp),y
    ldx print4x8_char
    beq +m
    lsr
    lsr
    lsr
    lsr
m:  and #$0f
    ora (d),y
    sta (d),y
    dey
    bpl -l

r:  ldx p_x
    ldy p_y
    rts

get_curchar_address:
    lda curchar
    sta d
    lda #0
    asl d
    rol
    asl d
    rol
    asl d
    rol
    clc
    adc #>charset
    sta @(++ d)
    rts

print_clear_curchar:
    jsr get_curchar_address
    ldy #7
    lda #0
l:  sta (d),y
    dey
    bpl -l
    rts

print4x8_dynalloc:
    pha

    jsr get_curchar_address

    ; Clear char if left half is being printed to.
    lda scrx2
    lsr
    sta scrx
    bcs +n
    ldy #7
    lda #0
l:  sta (d),y
    dey
    bpl -l
n:

    ; Plot char.
    jsr scrcoladdr
    lda curchar
    sta (scr),y
    lda curcol
    sta (col),y

    lda scrx2
    lsr
    pla
    jsr print4x8

    ; Step to next char if required.
    lda scrx2
    lsr
    bcc +r
    inc curchar
    lda d
    clc
    adc #8
    sta d
    lda @(++ d)
    adc #0
    sta @(++ d)

r:  inc scrx2
    rts

print_string_ay:
    sta s
    sty @(++ s)

; X: Number of chars
; scrx2/scry: Text position
; curchar: Character to print into.
print_string:
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

print_char:
    ldy #0
    lda (s),y
    bmi +n
    jsr print4x8_dynalloc
    lda #0
n:  inc s
    bne +n
    inc @(++ s)
n:  rts
