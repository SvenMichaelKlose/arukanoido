make_score_screen:
    lda #foreground
    sta curchar

print_hiscore_label:
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

    lda curchar
    sta scorechar_start

    rts

display_score:
    lda scorechar_start
    sta curchar

    ; Print score.
    lda #white
    sta curcol
    lda score1_x
    sta scrx2
    lda score1_y
    sta scry
    lda #<score
    sta s
    lda #>score
    sta @(++ s)
    jsr print_score_string
    inc curchar

    ; Print hiscore.
    lda hiscore1_x
    sta scrx2
    lda hiscore1_y
    sta scry
    lda #<hiscore
    sta s
    lda #>hiscore
    sta @(++ s)
    jsr print_score_string
    inc curchar

    ; Print score.
    lda score2_x
    sta scrx2
    lda score2_y
    sta scry
    lda #<score
    sta s
    lda #>score
    sta @(++ s)
    jsr print_score_string
    inc curchar

    rts

; scrx2/scry: Text position
; curchar: Character to print into.
print_score_string:
    jsr print_clear_curchar

    lda #0
    sta print_score_tmp
    ldx #num_score_digits
    ldy #0
l:  txa
    pha
    tya
    pha
    lda (s),y
    ora print_score_tmp
    sta print_score_tmp
    lda (s),y
    bne +n
    ldx print_score_tmp
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
