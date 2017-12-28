roundstart:
    ldx #0
l:  lda txt_round_nn,x
    sta txt_tmp,x
    cmp #255
    beq +n
    inx
    jmp -l
n:

    ; Copy round number digits into round message.
    lda #score_char0
    sta @(+ txt_tmp 8)
    lda level
l:  sec
    sbc #10
    bcc +n
    inc @(+ txt_tmp 8)
    jmp -l
n:  clc
    adc #@(+ 10 (char-code #\0) (- score_char0 (char-code #\0)))
    sta @(+ txt_tmp 9)

    ; Print "ROUND XX".
    lda #white
    sta curcol
    lda #16
    sta curchar
    lda #10
    sta scrx2
    lda #txt_round_nn_y
    sta scry
    lda #<txt_tmp
    sta s
    lda #>txt_tmp
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

n:  ldx #60
    jsr wait

    ; Print "READY".
    inc curchar
    lda #12
    sta scrx2
    lda #txt_round_nn_y
    clc
    adc #2
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
