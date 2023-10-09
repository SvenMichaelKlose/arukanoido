make_score_screen:
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
    sta s
    lda #>txt_1up
    sta @(++ s)
    jsr print_string

    ; Print "HIGH SCORE".
    lda txt_hiscore1_x
    sta scrx2
    lda txt_hiscore1_y
    sta scry
    ldx #10
    lda #<txt_hiscore
    sta s
    lda #>txt_hiscore
    sta @(++ s)
    jsr print_string

    lda has_two_players
    beq +n

    ; Print 2UP
    lda txt_2up_x
    sta scrx2
    lda txt_2up_y
    sta scry
    ldx #10
    lda #<txt_2up
    sta s
    lda #>txt_2up
    sta @(++ s)
    jsr print_string
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
    jsr print_score_string
    rts

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
    jsr print_score_string
    rts

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
    jsr print_score_string
    rts

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
