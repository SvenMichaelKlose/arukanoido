roundstart:
    lda level
    cmp #doh_level
    bne +n
    lda #snd_doh_round
    jmp play_sound
n:

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
    lda playfield_yc
    clc
    adc #20
    sta scry
    lda #<txt_tmp
    sta s
    lda #>txt_tmp
    sta @(++ s)
    ldx #255
    jsr print_string

    lda #snd_round
    jsr play_sound

    ldx #60
    jsr wait

    ; Print "PLAYER x".
    ldy active_player
    beq +n
    ldx #<txt_player1
    ldy #>txt_player1
    bne +o ; (jmp)
m:  ldx #<txt_player2
    ldy #>txt_player2
o:  stx s
    sty @(++ s)
    lda #7
    sta scrx2
    lda playfield_yc
    clc
    adc #20
    clc
    adc #2
    sta scry
    ldx #255
    jsr print_string


    ; Print "READY".
    inc curchar
    lda #12
    ldy active_player
    beq +n
    clc
    adc #5
n:  sta scrx2
    lda playfield_yc
    clc
    adc #20
    clc
    adc #2
    sta scry
    lda #<txt_ready
    sta s
    lda #>txt_ready
    sta @(++ s)
    ldx #255
    jsr print_string

    jsr wait_for_silence

    ; Remove message.
    lda #1
    sta scrx
l:  lda playfield_yc
    clc
    adc #20
    sta scry
    lda #0
    jsr plot_char
    inc scry
    inc scry
    lda #0
    jsr plot_char
    inc scrx
    lda scrx
    cmp #13
    bne -l

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
txt_player1:    @(string4x8 " PLAYER 1") 255
txt_player2:    @(string4x8 " PLAYER 2") 255
__end_round_start:
