show_charset:
    sei
    lda #$7f
    sta $912e
    sta $912d

    lda #1
    sta is_landscape
    jsr set_format
    0
    clrmw <screen >screen @(low 512) @(high 512)
    setmw <colors >colors @(low 512) @(high 512) white
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
    cmp #16
    bne -l
    inc scry
    lda scry
    cmp #16
    bne -l2
w:  jmp -w
