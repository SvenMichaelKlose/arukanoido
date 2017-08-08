make_score_screen:
    lda #foreground
    sta curchar
make_score_screen_title:
    ; Print "HIGH SCORE".
    lda #red
    sta curcol
    lda #10
    sta scrx2
    lda #0
    sta scry
    ldx #10
    lda #<txt_hiscore
    sta s
    lda #>txt_hiscore
    sta @(++ s)
    jsr print_string
    inc curchar
    lda curchar
    sta scorechar_start
    rts

display_score:
    sei
    lda scorechar_start
    sta curchar

    ; Print score.
    lda #white
    sta curcol
    lda #0
    sta scrx2
    lda #1
    sta scry
    lda #<score
    sta s
    lda #>score
    sta @(++ s)
    jsr print_score_string

    ; Print hiscore.
    inc curchar
    lda #12
    sta scrx2
    lda #<hiscore
    sta s
    lda #>hiscore
    sta @(++ s)
    jsr print_score_string
    inc curchar
    cli
    rts

; scrx2/scry: Text position
; curchar: Character to print into.
print_score_tmp:    0
print_score_string:
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
