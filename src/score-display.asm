make_score_screen:
    ; Print "HIGH SCORE".
    lda #red
    sta curcol
    lda #foreground
    sta curchar
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
    ldy curchar
    iny
    sty scorechar_start
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

; X: Number of chars
; scrx2/scry: Text position
; curchar: Character to print into.
print_string:
    ldy #0
l:  tya
    pha
    lda (s),y
    bmi +r
    jsr print4x8_dynalloc
    pla
    tay
    iny
    dex
    bne -l
    rts
r:  pla
    rts

print4x8_dynalloc:
    pha

    ; Get char address.
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

    ; Clear char if left half is being printed to.
    lda scrx2
    lsr
    sta scrx
    bcs +n
    ldy #7
    lda #0
l:  sta (d),y
    dey
    bpl -l
n:

    ; Plot char.
    jsr scrcoladdr
    lda curchar
    sta (scr),y
    lda curcol
    sta (col),y

    lda scrx2
    lsr
    pla
    jsr print4x8

    ; Step to next char if required.
    lda scrx2
    lsr
    bcc +r
    inc curchar
    lda d
    clc
    adc #8
    sta d
    lda @(++ d)
    adc #0
    sta @(++ d)

r:  inc scrx2
    rts
