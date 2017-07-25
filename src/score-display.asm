num_score_chars = 32
score_chars     = @(- (half num_chars) num_score_chars)
score_charset   = @(+ charset (* 8 score_chars))
txt_hiscore_charset = @(+ score_charset 40)
score_current_charset = @(+ score_charset (* screen_columns 8))
score_hiscore_charset = @(+ score_current_charset 48)

make_score_screen:
    ; Clear charset.
    lda #0
    tax
l:  sta score_charset,x
    dex
    bne -l

    ; Make screen chars.
    ldx #@(* 2 screen_columns)
    ldy #0
    lda #score_chars
l:  sta screen,y
    clc
    adc #1
    iny
    dex
    bne -l

    ; Set colours.
    ldx #@(-- screen_columns)
l:  lda #red
    sta colors,x
    lda #white
    sta @(+ colors screen_columns),x
    dex
    bpl -l

    ; Print "HIGH SCORE".
    ldx #$ff
    lda #<txt_hiscore_charset
    sta d
    lda #>txt_hiscore_charset
    sta @(++ d)
    lda #<txt_hiscore
    sta s
    lda #>txt_hiscore
    sta @(++ s)
    jmp print_string

display_score:
    ; Print score.
    ldx #num_score_digits
    lda #<score_current_charset
    sta d
    lda #>score_current_charset
    sta @(++ d)
    lda #<score
    sta s
    lda #>score
    sta @(++ s)
    jsr print_string

    ; Print hiscore.
    ldx #num_score_digits
    lda #<score_hiscore_charset
    sta d
    lda #>score_hiscore_charset
    sta @(++ d)
    lda #<hiscore
    sta s
    lda #>hiscore
    sta @(++ s)

; X: Number of chars
print_string:
    ldy #0
print_string2:
l:  tya
    lsr
    lda (s),y
    bmi +r
    php
    jsr print4x8
    plp
    bcc +n
    lda d
    clc
    adc #8
    sta d
    lda @(++ d)
    adc #0
    sta @(++ d)
n:  iny
    dex
    bne -l
r:  rts
