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
    sec
    sbc #32
    jsr print4x8_dynalloc

inc_s:
    inc s
    bne +r
    inc @(++ s)
r:  rts

hiscore_table:
    jsr clear_screen
    lda #1
    sta curchar

    lda #red
    sta curcol
    lda #<txt_enter
    sta s
    lda #>txt_enter
    sta @(++ s)
    lda #10
    sta scrx2
    lda #3
    sta scry
    jsr print_string

    lda #white
    sta curcol
    lda #10
    sta scry
    lda #5
    sta c
    lda #<txt_first
    sta s
    lda #>txt_first
    sta @(++ s)

l:  lda #10
    sta scrx2
    jsr print_string

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
    sta s
    lda #>scores
    sta @(++ s)
    lda #10
    sta scry
    lda #5
    sta c
l:  lda #14
    sta scrx2
    jsr print_score_string

    lda #num_score_digits
    jsr add_sb
    lda #22
    sta scrx2
    inc curchar
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

scores:
    0 0 0 0 0 0 0 "AAA"
    0 0 0 0 0 0 0 "AAA"
    0 0 0 0 0 0 0 "AAA"
    0 0 0 0 0 0 0 "AAA"
    0 0 0 0 0 0 0 "AAA"
__end_hiscore:
