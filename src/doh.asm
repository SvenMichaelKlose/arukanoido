first_doh_char = @(+ foreground (half foreground))

init_doh_charset:
    ldx #@(* 15 16)
l:  lda @(-- gfx_doh_a),x
    sta @(-- (+ charset (* 8 first_doh_char))),x
    lda @(-- gfx_doh_b),x
    sta @(-- (+ charset (* 8 (+ framechars first_doh_char)))),x
    dex
    bne -l
    rts

draw_doh:
    ; Clear brick map.
    0
    clrmw <bricks >bricks 0 2
    0

    lda #@first_doh_char
    sta tmp
    lda #5
    sta scrx
    lda #5      ; (number of columns)
    sta tmp3

l2: lda #7
    sta scry
    lda #12     ; (number of rows)
    sta tmp2
l:  jsr scrcoladdr
    jsr scr2brick_in_d
    lda tmp
    sta (scr),y
    sta (d),y
    lda #yellow
    sta (col),y
    inc scry
    inc tmp
    lda tmp
    cmp #@(+ first_doh_char 30)
    bne +n
    lda #@(+ framechars first_doh_char)
    sta tmp
n:  dec tmp2
    bne -l
    inc scrx
    dec tmp3
    bne -l2

    rts

; A: colour
flash_doh:
    lda flashing_doh
    beq +r
    lda #white
    dec flashing_doh
    bne +l3
    lda #yellow

l3: sta tmp
    lda #5
    sta scrx
    lda #5      ; (number of columns)
    sta tmp3

l2: lda #7
    sta scry
    lda #12     ; (number of rows)
    sta tmp2
l:  jsr scrcoladdr
    lda tmp
    sta (col),y
    inc scry
    dec tmp2
    bne -l
    inc scrx
    dec tmp3
    bne -l2

r:  rts
