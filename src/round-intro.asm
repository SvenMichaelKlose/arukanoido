__start_round_intro:

draw_round_intro_background:
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
    jmp draw_bitmap

;;; In:
;;;   A:  Tune index.
;;;   XY: Text
round_intro:
    ;; Save tune index.
    sta tmp

    ;; Save text address.
    tya
    pha
    txa
    pha
    lda tmp
    pha

    ;; Draw scores, stars and ship.
    jsr draw_round_intro_background

    ;; Start tune now that one can see something.
    pla
    jsr play_sound

    ;; Let ship engines flicker.
if @*has-digis?*
    lda is_playing_digis
    bne +n
end
    jsr init_raster
if @*has-digis?*
n:
end

    ;; Save first char index to restart page.
    lda curchar
    sta tmp4

    jsr unblank_screen

    ;; Init text start.
    pla
    sta sl
    pla
    sta sh

    ;; Go to home position of page.
round_intro_home:
    ldx playfield_yc
    inx
    stx scry
    lda tmp4
    sta curchar
    lda #white
    sta curcol

    ;; Print line.
round_intro_line:
if @*shadowvic?*
    $22 $02         ; Wait for retrace.
end

    ; Move to line start.
    lda #0
    sta scrx2
    jsr scrcoladdr
    jsr get_curchar_addr

round_intro_char:
    ; Get char/code.
    ldy #0
    lda (s),y
    bmi +n  ; It's a code...

    ; Draw char.
    pha
    jsr print4x8_dynalloc
    pla

    ; Step to next char.
n:  inc sl
    bne +n
    inc sh

    ;; Handle newline.
n:  cmp #254
    bne +n
    inc scry
    inc scry
    inc curchar
    jmp round_intro_line

    ;; Handle end of text.
n:  cmp #253
    beq +r      ; No more pages.
    cmp #255
    beq end_of_page  ; End of page.

    ;; End intro on fire.
    lda level
    ; But not when games has been finished.
    cmp #@(+ 1 doh_level)
    beq +n
    jsr test_fire_and_release
    bcs +r

    ; Delay after each char.
n:  ldx #2
    jsr wait

    jmp round_intro_char

    ;; End of text page.
end_of_page:
    ldx #15
    jsr wait
    lda level
    ; (Wait a bit longer if extro.)
    cmp #@(+ 1 doh_level)
    bne +n
    ldx #60
    jsr wait
n:  jsr clear_intro_text
    jmp round_intro_home

    ;; End of intro.
    ; Back to game IRQ handling.
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
    and #31 ; (Reduce probability of retries.)
    cmp #15
    bcs -l1 ; Over the right. Try again...
    sta scrx
l:  jsr random
    and #31 ; (Reduce probability of retries.)
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
    ; (jmp clear_intro_text)

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
