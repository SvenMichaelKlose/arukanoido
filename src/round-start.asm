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
chars_ready = @(+ chars_round len_round)
charset_round = @(+ charset (* 8 chars_round))
charset_ready = @(+ charset (* 8 chars_ready))

roundstart:
    ; Copy round number digits into round message.
    lda #score_char0
    sta @(+ txt_round_nn 7)
    lda level
l:  sec
    sbc #10
    bcc +n
    inc @(+ txt_round_nn 7)
    jmp -l
n:  clc
    adc #@(+ 10 (char-code #\0) (- score_char0 (char-code #\0)))
    sta @(+ txt_round_nn 8)

    ; Clear bitmaps
    0
    c_clrmb <charset_round >charset_round @(* 8 len_round_chars)
    c_clrmb <charset_ready >charset_ready @(* 8 len_ready_chars)
    0

    ; Make bitmap chars for "ROUND XX".
    lda #<screen_round
    sta d
    lda #>screen_round
    sta @(++ d)
    ldx #5
    lda #chars_round
    jsr make_4x8_line

    ; Make bitmap chars for "READY".
    lda #<screen_ready
    sta d
    lda #>screen_ready
    sta @(++ d)
    ldx #3
    lda #chars_ready
    jsr make_4x8_line

    ; Make colors.
    ldx #@(half len_round)
    lda #white
l:  sta colors_round,x
    sta colors_ready,x
    dex
    bpl -l

    ; Print "ROUND XX".
    txt_round_nnm = @(-- txt_round_nn)
    0
    c_setsd <txt_round_nnm >txt_round_nnm <charset_round >charset_round
    0
    ldx #len_round
    ldy #1
    jsr print_string2

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
    txt_readym = @(-- txt_ready)
    0
    c_setsd <txt_readym >txt_readym <charset_ready >charset_ready
    0
    ldx #len_ready
    ldy #1
    jsr print_string2

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

txt_round_nn:   @(string4x8 "ROUND  XX")
txt_ready:      @(string4x8 "READY")
