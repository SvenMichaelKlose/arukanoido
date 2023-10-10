txt_enter:      @(string4x8 "ENTER YOUR INITIALS !") 255
txt_hiscore:    @(string4x8 "HIGH ")
txt_score:      @(string4x8 "SCORE") 255
txt_round:      @(string4x8 "ROUND") 255
txt_name:       @(string4x8 "NAME") 255
txt_all:        @(string4x8 "ALL") 255
txt_first:      @(string4x8 "1ST") 255
txt_second:     @(string4x8 "2ND") 255
txt_third:      @(string4x8 "3RD") 255
txt_fourth:     @(string4x8 "4TH") 255
txt_fifth:      @(string4x8 "5TH") 255

print_initial_char:
    ldy #0
    lda (s),y
    jsr print4x8_dynalloc

inc_s:
    inc sl
    bne +r
    inc sh
r:  rts

hiscore_table:
    jsr clear_screen
    lda #1
    sta curchar

    lda #red
    sta curcol
    lda #<txt_enter
    sta sl
    lda #>txt_enter
    sta sh
    lda #10
    sta scrx2
    lda #3
    sta scry
    jsr print_string
    inc curchar

    lda #yellow
    sta curcol
    lda #8
    sta scry

    lda #16
    sta scrx2
    lda #<txt_score
    sta sl
    lda #>txt_score
    sta sh
    jsr print_string
    inc curchar

    lda #22
    sta scrx2
    lda #<txt_round
    sta sl
    lda #>txt_round
    sta sh
    jsr print_string
    inc curchar

    lda #28
    sta scrx2
    lda #<txt_name
    sta sl
    lda #>txt_name
    sta sh
    jsr print_string
    inc curchar

    lda #white
    sta curcol
    lda #10
    sta scry
    lda #5
    sta c
    lda #<txt_first
    sta sl
    lda #>txt_first
    sta sh

l:  lda #10
    sta scrx2
    jsr print_string
    inc curchar
    inc scry
    inc scry

    ldy #0
m:  lda (s),y
    bmi +n
    jsr inc_s
    jmp -m

n:  jsr inc_s
    dec c
    bne -l

    ;; Print scores and initials.
    lda #<scores
    sta sl
    lda #>scores
    sta sh
    lda #10
    sta scry
    lda #5
    sta c
l:  lda #14
    sta scrx2
    jsr print_score_string
    inc curchar

    lda #num_score_digits
    jsr add_sb

    ; Print round number.
n:  ldy #25
    sty scrx2
    ldy #0
    lda (s),y
    jsr inc_s
    ldx #0
m:  sec
    sbc #10
    inx
    beq -m
    bcs -m
    clc
    adc #10
    dex
    beq +n
    pha
    txa
    clc
    adc #score_char0
    jsr print4x8_dynalloc
    pla
n:  ldy #26
    sty scrx2
    clc
    adc #score_char0
    jsr print4x8_dynalloc
    inc curchar

    ; Print name.
    lda #29
    sta scrx2
    jsr print_initial_char
    jsr print_initial_char
    jsr print_initial_char
    inc curchar

    inc scry
    inc scry
    dec c
    bne -l

w:  jsr poll_keypress
    bcc -w
    rts

initial_chars:
    @(string4x8 "ABCDEFGHIJKLMNOPQRSTUVWXYZ.! ")

scores:
    5 0 0 0 0 0 0 5 @(string4x8 "SSB")
    4 5 0 0 0 0 0 4 @(string4x8 "SND")
    4 0 0 0 0 0 0 3 @(string4x8 "TOR")
    3 5 0 0 0 0 0 2 @(string4x8 "ONJ")
    3 0 0 0 0 0 0 1 @(string4x8 "AKR")
__end_hiscore:
