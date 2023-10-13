hiscore_yc = 16

txt_hiscore_h1: @(string4x8 "THE FOLLOWING ARE") 255
txt_hiscore_h2: @(string4x8 "THE RECORDS OF THE BRAVEST") 255
txt_hiscore_h3: @(string4x8 "FIGHTERS OF ARUKANOIDO") 255
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

print_score_heading:
    lda #<txt_score
    ldy #>txt_score
    jsr print_string_ay
    inc curchar

    lda scrx2
    clc
    adc #1
    sta scrx2
    lda #<txt_round
    ldy #>txt_round
    jsr print_string_ay
    inc curchar

    lda scrx2
    clc
    adc #1
    sta scrx2
    lda #<txt_name
    ldy #>txt_name
    jsr print_string_ay
    inc curchar
    rts

hiscore_table:
    jsr clear_screen
    lda #1
    sta curchar
    jsr print_scores_and_labels

    jsr clear_curchar
    lda #yellow
    sta curcol
    lda #7
    sta scrx2
    lda playfield_yc
    clc
    adc #6
    sta scry
    lda #<txt_hiscore_h1
    ldy #>txt_hiscore_h1
    jsr print_string_ay
    inc curchar

    inc scry
    inc scry
    lda #2
    sta scrx2
    lda #<txt_hiscore_h2
    ldy #>txt_hiscore_h2
    jsr print_string_ay
    inc curchar

    inc scry
    inc scry
    lda #4
    sta scrx2
    lda #<txt_hiscore_h3
    ldy #>txt_hiscore_h3
    jsr print_string_ay
    inc curchar

    jmp +n
    lda #red
    sta curcol
    lda #5
    sta scrx2
    lda playfield_yc
    clc
    adc #3
    sta scry
    lda #<txt_enter
    ldy #>txt_enter
    jsr print_string_ay
    inc curchar
n:

    lda #4
    sta tmp4

    lda #yellow
    sta curcol
    lda playfield_yc
    clc
    adc #16
    sta scry
    lda tmp4
    clc
    adc #6
    sta scrx2
    jsr print_score_heading

    lda #white
    sta curcol
    lda playfield_yc
    clc
    adc #18
    sta scry
    lda #5
    sta c
    lda #<txt_first
    sta sl
    lda #>txt_first
    sta sh

l:  lda tmp4
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

    lda playfield_yc
    clc
    adc #18
    sta scry
    lda #<scores
    sta sl
    lda #>scores
    sta sh
    lda #5
    sta c
l:  jsr print_score_round_name
    inc scry
    inc scry
    dec c
    bne -l

    rts


;;; Print scores and initials.
print_score_round_name:
    lda tmp4
    clc
    adc #4
    sta scrx2
    jsr print_score_string
    inc curchar

    lda #num_score_digits
    jsr add_sb

    ; Print round number.
n:  lda tmp4
    clc
    adc #15
    sta scrx2
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
n:  pha
    lda tmp4
    clc
    adc #16
    sta scrx2
    pla
    clc
    adc #score_char0
    jsr print4x8_dynalloc
    inc curchar

    ; Print initials.
    lda tmp4
    clc
    adc #19
    sta scrx2
    jsr clear_curchar
    jsr print_initial_char
    jsr print_initial_char
    jsr print_initial_char
    inc curchar
    rts

initial_chars:
    @(string4x8 "ABCDEFGHIJKLMNOPQRSTUVWXYZ.! ")

scores:
    0 0 5 0 0 0 0 5 @(string4x8 "SSB")
    0 0 4 5 0 0 0 4 @(string4x8 "SND")
    0 0 4 0 0 0 0 3 @(string4x8 "TOR")
    0 0 3 5 0 0 0 2 @(string4x8 "ONJ")
    0 0 3 0 0 0 0 1 @(string4x8 "AKR")
__end_hiscore:
