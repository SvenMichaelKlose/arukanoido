init_doh_charset:
    ldx #@(* 15 16)
l:  lda @(-- gfx_doh_a),x
    sta @(-- (+ charset (* 8 (+ foreground (half foreground))))),x
    lda @(-- gfx_doh_b),x
    sta @(-- (+ charset (* 8 (+ framechars foreground (half foreground))))),x
    dex
    bne -l
    rts

draw_doh:
    lda #@(+ foreground (half foreground))
    sta tmp
    lda #5
    sta scrx
    lda #5
    sta tmp3

l2: lda #7
    sta scry
    lda #12
    sta tmp2
l:  jsr scrcoladdr
    lda tmp
    sta (scr),y
    lda #yellow
    sta (col),y
    inc scry
    inc tmp
    lda tmp
    cmp #@(+ foreground (half foreground) 30)
    bne +n
    lda #@(+ framechars foreground (half foreground))
    sta tmp
n:  dec tmp2
    bne -l
    inc scrx
    dec tmp3
    bne -l2

    rts
