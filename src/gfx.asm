init_game_mode:
    ; Clear character 0.
    ldx #7
    lda #0
l:  sta charset,x
    dex
    bpl -l

    ; Copy background characters to charset.
    ldx #@(- gfx_background_end gfx_background)
l:  lda @(-- gfx_background),x
    sta @(-- (+ charset (* bg_start 8))),x
    dex
    bne -l

    ; Copy DOH into charset.
    ldx #@(* 15 16)
l:  lda @(-- gfx_doh_a),x
    sta @(-- (+ charset (* 8 (+ foreground (half foreground))))),x
    lda @(-- gfx_doh_b),x
    sta @(-- (+ charset (* 8 (+ framechars foreground (half foreground))))),x
    dex
    bne -l

    ; Check if it's NTSC or PAL.
    lda $ede4
    cmp #$0c
    beq +pal

ntsc:
    lda #12         ; Horizontal screen origin.
    sta $9000
    lda #5          ; Vertical screen origin.
    sta $9001
    jmp +n

pal:
    lda #20         ; Horizontal screen origin.
    sta $9000
    lda #21         ; Vertical screen origin.
    sta $9001

n:  lda #15         ; Number of columns.
    sta $9002
    lda #@(* 32 2)  ; Number of rows.
    sta $9003
    lda #@(+ vic_screen_1000 vic_charset_1400)
    sta $9005
    lda $900e
    and #$0f
    ora #@(* light_cyan 16) ; Auxiliary color.
    sta $900e
    lda #@(+ reverse red)   ; Screen and border color.
    sta $900f

    rts
