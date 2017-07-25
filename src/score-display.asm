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

    ; Set colours.
    ldx #@(-- screen_columns)
l:  lda #red
    sta colors,x
    lda #white
    sta @(+ colors screen_columns),x
    dex
    bpl -l

    ; Print "HIGH SCORE".
    lda #red
    sta curcol
    lda #96
    sta curchar
    lda #5
    sta scrx
    lda #0
    sta scry
    ldx #10
    lda #<txt_hiscore
    sta s
    lda #>txt_hiscore
    sta @(++ s)
    jsr print_string
    ldy curchar
    iny
    sty scorechar_start
    rts

display_score:
    lda scorechar_start
    sta curchar

    ; Print score.
    lda #white
    sta curcol
    lda #0
    sta scrx
    lda #1
    sta scry
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
    inc curchar
    lda #6
    sta scrx
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
; scrx/scry: Text position
; curchar: Character to print into.
print_string:
    lda curchar
    sta d
    lda #0
    asl d
    rol
    asl d
    rol
    asl d
    rol
    clc
    adc #>charset
    sta @(++ d)

    ldy #7
    lda #0
l:  sta (d),y
    dey
    bpl -l

    ldy #0
l:  tya
    lsr
    php
    tya
    pha
    jsr scrcoladdr
    lda curchar
    sta (scr),y
    lda curcol
    sta (col),y
    pla
    tay
    plp
    lda (s),y
    bmi +r
    php
    jsr print4x8
    plp
    bcc +n
    inc curchar
    inc scrx
    lda d
    clc
    adc #8
    sta d
    lda @(++ d)
    adc #0
    sta @(++ d)

    tya
    pha
    ldy #7
    lda #0
l2: sta (d),y
    dey
    bpl -l2
    pla
    tay

n:  iny
    dex
    bne -l
r:  rts
