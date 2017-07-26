roundstart:
    ; Copy round number digits into round message.
    lda #score_char0
    sta @(+ txt_round_nn 8)
    lda level
l:  sec
    sbc #10
    bcc +n
    inc @(+ txt_round_nn 8)
    jmp -l
n:  clc
    adc #@(+ 10 (char-code #\0) (- score_char0 (char-code #\0)))
    sta @(+ txt_round_nn 9)

    ; Print "ROUND XX".
    lda #white
    sta curcol
    lda #16
    sta curchar
    lda #5
    sta scrx
    lda #22
    sta scry
    lda #<txt_round_nn
    sta s
    lda #>txt_round_nn
    sta @(++ s)
    ldx #255
    jsr print_string

    lda #snd_round
    jsr play_sound

    ldx #130
l:  lda $9004
    lsr
    bne -l
n:  lda $9004
    lsr
    bne -n
    dex
    bne -l

    ; Print "READY".
    inc curchar
    lda #6
    sta scrx
    lda #24
    sta scry
    lda #<txt_ready
    sta s
    lda #>txt_ready
    sta @(++ s)
    ldx #255
    jsr print_string

    jsr wait_sound

    ; Remove message.
screen_round = @(+ screen (* 15 22) 5)
screen_ready = @(+ screen (* 15 24) 6)
    0
    c_clrmb <screen_round >screen_round 5
    c_clrmb <screen_ready >screen_ready 5
    0
    rts

make_4x8_line:
    ldy #0
l:  sta (d),y
    clc
    adc #1
    iny
    dex
    bne -l
    rts

txt_round_nn:   @(string4x8 " ROUND  XX") 255
txt_ready:      @(string4x8 " READY") 255
