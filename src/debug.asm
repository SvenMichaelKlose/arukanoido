show_charset:
    0
    c_clrmw <screen >screen @(low 512) @(high 512)
    c_setmw <colors >colors @(low 512) @(high 512) white
    0

    lda #0
    sta scry
    sta tmp
l2: lda #0
    sta scrx
l:  jsr scraddr
    lda tmp
    sta (scr),y
    inc tmp
    inc scrx
    lda scrx
    cmp #8
    bne -l
    inc scry
    lda scry
    cmp #32
    bne -l2
sei
w:  jmp -w
