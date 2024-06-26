__start_round_start:

roundstart:
    lda level
    cmp #doh_level
    bne +n
    lda #snd_doh_round
    jmp play_sound

n:  ldx #0
l:  lda txt_round_nn,x
    sta scratch,x
    cmp #255
    beq +n
    inx
    jmp -l

    ; Copy round number digits into round message.
n:  lda #score_char0
    sta @(+ scratch 8)
    lda level
l:  sec
    sbc #10
    bcc +n
    inc @(+ scratch 8)
    jmp -l
n:  clc
    adc #@(+ 10 (char-code #\0) (- score_char0 (char-code #\0)))
    sta @(+ scratch 9)

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
    lda #<scratch
    ldy #>scratch
    jsr print_string_ay
    inc curchar

    lda #snd_round
    jsr play_sound

    ldx #60
    jsr wait

    ; Print "PLAYER X".
    lda has_two_players
    beq +n
    jsr clear_curchar
    ldy active_player
    dey
    bne +m
    ldx #<txt_player1
    ldy #>txt_player1
    bne +o ; (jmp)
m:  ldx #<txt_player2
    ldy #>txt_player2
o:  stx sl
    sty sh
    lda #7
    sta scrx2
    lda playfield_yc
    clc
    adc #20
    clc
    adc #2
    sta scry
    inc curchar
    jsr clear_curchar
    jsr print_string
    inc curchar

    ; Print "READY".
n:  jsr clear_curchar
    lda #12
    ldy has_two_players
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
    ldy #>txt_ready
    jsr print_string_ay
    inc curchar

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

if @*brickfx?*
    jsr start_brick_fx
    lda #8
    sta tmp
l:  ldx #1
    jsr wait
    jsr do_brick_fx
    dec tmp
    bne -l
end

    rts

clear_curchar:
    lda curchar
    jsr get_char_addr
    jmp blit_clear_char

txt_round_nn:   @(string4x8 " ROUND  XX") 255
txt_ready:      @(string4x8 " READY") 255
txt_player1:    @(string4x8 " PLAYER 1") 255
txt_player2:    @(string4x8 " PLAYER 2") 255

__end_round_start:
