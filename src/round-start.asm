len_round       = 9
len_round_chars = 5
len_ready       = 5
len_ready_chars = 3
ofs_round = @(+ (* 15 22) 5)
ofs_ready = @(+ (* 15 24) 6)
screen_round = @(+ screen ofs_round)
screen_ready = @(+ screen ofs_ready)
colors_round = @(+ colors ofs_round)
colors_ready = @(+ colors ofs_ready)
chars_round = @(quarter framechars)
chars_ready = @(+ chars_round len_round_chars)
charset_round = @(+ charset (* 8 chars_round))
charset_ready = @(+ charset (* 8 chars_ready))

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

    ; Clear bitmaps
    0
    c_clrmb <charset_round >charset_round @(* 8 len_round_chars)
    c_clrmb <charset_ready >charset_ready @(* 8 len_ready_chars)
    0

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
