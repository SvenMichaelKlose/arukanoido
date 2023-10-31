__start_round_intro:

draw_round_intro_background:
    lda $9002
    pha

    jsr blank_screen
    jsr clear_screen
    jsr make_stars
    lda #5
    sta curchar
    jsr print_scores_and_labels

    ; Draw ship.
    lda #@(+ multicolor blue)
    sta curcol
    lda #1
    sta scrx
    lda playfield_yc
    clc
    adc #16
    sta scry
    lda #<gfx_ship
    ldy #>gfx_ship
    jsr draw_bitmap

    jsr wait_retrace    ; Avoid garbage lighting up on screen.
    pla
    sta $9002
    rts

;;; In:
;;;   A:  Tune index.
;;;   XY: Text
round_intro:
    ;; Save tune index.
    sta tmp
    tya
    pha

    ;; Save text address.
    txa
    pha
    lda tmp
    pha

    ;; Draw scores, stars and ship.
    jsr draw_round_intro_background

    ;; Start tune now that one can see something.
    pla
    jsr play_sound

    ;; Init text start.
    pla
    sta sl
    pla
    sta sh

    ;; Let ship engines flicker.
    jsr init_raster

    ;; Save first char value for each page
    lda curchar
    sta tmp4

    ;; Home position of page.
l5: ldx playfield_yc
    inx
    stx scry
    lda tmp4
    sta curchar
    lda #white
    sta curcol

    ;; Print char and step on.
l:
if @*shadowvic?*
    $22 $02         ; Wait for retrace.
end
    ; Move to line start.
    lda #0
    sta scrx2
    ; Print char.
l2: ldy #0
    lda (s),y
    bmi +n
    jsr print4x8_dynalloc
n:  inc sl
    bne +n
    inc sh

    ;; Handle newline.
n:  cmp #254
    bne +n
    inc scry
    inc scry
    inc curchar
    jmp -l

    ;; Handle end of text.
n:  cmp #253
    beq +r      ; No more pages.
    cmp #255
    beq +m      ; End of page.

    ;; End intro on fire.
    lda level
    cmp #@(+ 1 doh_level)
    beq +n
    jsr test_fire_and_release
    bcs +r
n:  ldx #2
    jsr wait
    jmp -l2

    ;; End of text page.
m:  ldx #15
    jsr wait
    lda level
    cmp #@(+ 1 doh_level)
    bne +l3
    ldx #60
    jsr wait
l3: jsr clear_intro_text
    jmp -l5

    ;; End of intro.
r:  jmp init_irq

make_stars:
    ldx #31
l:  lda bg_stars,x
    sta @(+ charset 8),x
    dex
    bpl -l

    ;; Set first char to allocate.
    lda #1
    sta curchar

    ; Init loop for 128 stars.
    lda #128
    sta tmp2
    ; Make random position.
l1: jsr random
    cmp #15
    bcs -l1
    sta scrx
l:  jsr random
    cmp playfield_yc
    bcc -l               ; Don't plot into score area…
    cmp yc_max
    bcs -l
    sta scry

    ; Make random colour.
    jsr random
    and #3
    tax
    lda star_colors,x
    sta curcol

    ; Make random star.
    jsr random
    and #3
    clc
    adc #1
    sta curchar
    lda scrx
    ldy scry
    jsr plot
    dec tmp2
    bne -l1

;; Clear text lines (including stars, I'm afraid).
clear_intro_text:
    lda #0
    sta scrx
l3: ldy playfield_yc
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

txt_game_won:
    @(string4x8 " DIMENSION-CONTROLLING FORT") 254
    @(string4x8 " \"DOH\" HAS NOW BEEN") 254
    @(string4x8 " DEMOLISHED, AND TIME") 254
    @(string4x8 " STARTED FLOWING REVERSELY.") 255
    @(string4x8 " \"VAUS\" MANAGED TO ESCAPE") 254
    @(string4x8 " FROM THE DISTORTED SPACE.") 255
    @(string4x8 " BUT THE REAL VOYAGE OF") 254
    @(string4x8 " \"ARKANOID\" IN THE GALAXY") 254
    @(string4x8 " HAS ONLY STARTED......") 255
    253

bg_stars:
    %00000000
    %00000000
    %01000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000

    %00000000
    %00000000
    %00000000
    %00000100
    %00000000
    %00000000
    %00000000
    %00000000

    %00000000
    %00000000
    %00000000
    %00000000
    %00010000
    %00000000
    %00000000
    %00000000

    %00000001
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000

star_colors:
    white cyan cyan blue

__end_round_intro:
