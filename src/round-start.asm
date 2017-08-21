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
    lda #10
    sta scrx2
    lda #txt_round_nn_y
    sta scry
    lda #<txt_round_nn
    sta s
    lda #>txt_round_nn
    sta @(++ s)
    ldx #255
    jsr print_string

    lda #snd_round
    jsr play_sound
    lda level
    cmp #33
    bne +n
    lda #snd_doh_round
    jsr play_sound

n:  lda #130
    jsr wait

    ; Print "READY".
    inc curchar
    lda #12
    sta scrx2
    lda #@(+ txt_round_nn_y 2)
    sta scry
    lda #<txt_ready
    sta s
    lda #>txt_ready
    sta @(++ s)
    ldx #255
    jsr print_string

    jsr wait_sound

    ; Remove message.
screen_round = @(+ screen (* screen_columns txt_round_nn_y) 5)
screen_ready = @(+ screen (* screen_columns (+ txt_round_nn_y 2)) 6)
    0
    c_clrmb <screen_round >screen_round 5
    c_clrmb <screen_ready >screen_ready 5
    0

    jsr start_brick_fx
    lda #8
    sta tmp
l:  ldx #1
    jsr wait
    jsr do_brick_fx
    dec tmp
    bne -l

    rts

txt_round_nn:   @(string4x8 " ROUND  XX") 255
txt_ready:      @(string4x8 " READY") 255
