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
    lda #playfield_yc
    clc
    adc #16
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

l5: lda #playfield_yc
    clc
    adc #1
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
    jsr test_fire
    beq +r2

    ldx #2
    jsr ship_flicker

    jmp -l2

r2: jsr wait_fire_released
r:  rts

m:  ldx #15
    jsr ship_flicker

    jsr clear_intro_text

    jmp -l5

make_stars:
    lda #bg_star
    sta curchar
    lda #white
    sta curcol

    lda #64
    sta make_stars_tmp
l1: jsr random
    cmp #15
    bcs -l1
    sta scrx
l:  jsr random
    cmp #playfield_yc
    bcc -l               ; Don't plot into score area…
    cmp #yc_max
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
    lda #0
    sta scrx
l3: ldy #playfield_yc
    iny
    sty scry
    lda #0
    jsr plot_char
    inc scry
    inc scry
    lda #0
    jsr plot_char
    inc scry
    inc scry
    lda #0
    jsr plot_char
    inc scry
    inc scry
    lda #0
    jsr plot_char
    inc scrx
    lda scrx
    cmp #14
    bne -l3
    rts

ship_flicker:
l4: lda $9004
    beq -l4

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
