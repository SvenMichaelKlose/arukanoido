init_scores_and_labels:
    lda #foreground
    sta curchar

print_scores_and_labels:
    lda #red
    sta curcol

    ; Print 1UP
    lda txt_1up_x
    sta scrx2
    lda txt_1up_y
    sta scry
    ldx #10
    lda #<txt_1up
    ldy #>txt_1up
    jsr print_string_ay

    ; Print "HIGH SCORE".
    lda txt_hiscore1_x
    sta scrx2
    lda txt_hiscore1_y
    sta scry
    ldx #10
    lda #<txt_hiscore
    ldy #>txt_hiscore
    jsr print_string_ay

    lda has_two_players
    beq +n

    ; Print 2UP
    jsr clear_curchar
    lda txt_2up_x
    sta scrx2
    lda txt_2up_y
    sta scry
    ldx #10
    lda #<txt_2up
    ldy #>txt_2up
    jsr print_string_ay
n:

    lda curchar
    sta score1_char_start
    jsr print_score1
    inc curchar

    lda curchar
    sta hiscore_char_start
    jsr print_hiscore
    inc curchar

    lda has_two_players
    beq +n

    lda curchar
    sta score2_char_start
    jsr print_score2
    inc curchar

n:  rts

print_score1:
    lda score1_char_start
    sta curchar
print_score1_raw:
    lda #white
    sta curcol
    lda score1_x
    sta scrx2
    lda score1_y
    sta scry
    lda #<score1
    sta s
    lda #>score1
    sta @(++ s)
    jmp print_score_string

print_hiscore:
    lda hiscore_char_start
    sta curchar
print_hiscore_raw:
    lda #white
    sta curcol
    lda hiscore1_x
    sta scrx2
    lda hiscore1_y
    sta scry
    lda #<hiscore
    sta s
    lda #>hiscore
    sta @(++ s)
    jmp print_score_string

print_score2:
    lda score2_char_start
    sta curchar
print_hiscore_raw:
    lda #white
    sta curcol
    lda score2_x
    sta scrx2
    lda score2_y
    sta scry
    lda #<score2
    sta s
    lda #>score2
    sta @(++ s)
    jmp print_score_string

; scrx2/scry: Text position
; curchar: Character to print into.
print_score_string:
    jsr print_clear_curchar

    lda #0
    sta tmp3
    ldx #num_score_digits
    ldy #0
l:  txa
    pha
    tya
    pha
    lda (s),y
    ora tmp3
    sta tmp3
    lda (s),y
    bne +n
    ldx tmp3
    bne +n
    cpy #@(- num_score_digits 2)
    bcc +m
n:  clc
    adc #score_char0
m:  jsr print4x8_dynalloc
    pla
    tay
    pla
    tax
    iny
    dex
    bne -l
r:  rts

txt_1up:    @(string4x8 "1UP") 255
txt_2up:    @(string4x8 "2UP") 255
