round_intro:
    jsr clear_screen
    jsr init_foreground
    jsr make_stars
    lda #1
    sta curchar
    jsr make_score_screen_title
    jsr display_score

    lda #@(+ multicolor blue)
    sta curcol
    lda #0
    sta scrx
    lda #18
    sta scry
    lda #<gfx_ship
    ldy #>gfx_ship
    jsr draw_bitmap

    lda curchar
    sta tmp4
    lda #white
    sta curcol

    lda #<txt_round_intro
    sta s
    lda #>txt_round_intro
    sta @(++ s)

    lda #snd_theme
    jsr play_sound

l5: lda #3
    sta scry
    lda tmp4
    sta curchar

l:  lda #0
    sta scrx2
l2: jsr print_char
    cmp #254
    bne +n
    inc scry
    inc scry
    inc curchar
    jmp -l
n:  cmp #253
    beq +r
    cmp #255
    beq +m

    ldx #2
    jsr wait

    jmp -l2

r:  rts

m:  ldx #15
    jsr wait

    jsr clear_intro_text

    jmp -l5

make_stars_tmp: 0

make_stars:
    lda #bg_star
    sta curchar
    lda #white
    sta curcol

    lda #64
    sta make_stars_tmp
l1: jsr random
    cmp #@(-- screen_columns)
    bcs -l1
    sta scrx
l:  jsr random
    cmp #@(-- screen_rows)
    bcs -l
    sta scry
    jsr random
    ldy #cyan
    lsr
    bcc +m
    ldy #white
    jmp +n
m:  lsr
    ldy #blue
n:  sty curcol
    lda scrx
    ldy scry
    jsr plot
    dec make_stars_tmp
    bne -l1

clear_intro_text:
    ldx #@(-- screen_columns)
    lda #0
l3: sta @(+ screen (* screen_columns 3)),x
    sta @(+ screen (* screen_columns 5)),x
    sta @(+ screen (* screen_columns 7)),x
    sta @(+ screen (* screen_columns 9)),x
    dex
    bpl -l3
    rts

wait_tmp: 0

wait:
l4: lda $9004
    beq -l4

    inc wait_tmp
    lda wait_tmp
    lsr
    ldy #@(* orange 16)
    bcc +n
    ldy #@(* light_cyan 16)
n:  sty tmp
    lda $900e
    and #15
    ora tmp
    sta $900e

l3: lda $9004
    bne -l3

    dex
    bne -l4
    rts

txt_round_intro:
    @(string4x8 " THE ERA AND TIME OF") 254
    @(string4x8 " THIS STORY IS UNKNOWN") 255
    @(string4x8 " AFTER THE MOTHERSHIP") 254
    @(string4x8 " \"ARKANOID\" WAS DESTROYED,") 254
    @(string4x8 " A SPACECRAFT \"VAUS\"") 254
    @(string4x8 " SCRAMBLED AWAY FROM IT.") 255
    @(string4x8 " BUT ONLY TO BE") 254
    @(string4x8 " TRAPPED IN SPACE WARPED") 254
    @(string4x8 " BY SOMEONE........") 255
    253
