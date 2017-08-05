; Calculate line address in screen.
scraddr:
    ldy scry
    lda line_addresses,y
    sta scr
    sta col
    cpy #@(++ (/ 256 screen_columns))
    lda #@(half (high screen))
    rol
    sta @(++ scr)
    ldy scrx
    rts

; Calculate line address in screen and colour memory.
scrcoladdr:
    ldy scry
    lda line_addresses,y
    sta scr
    sta col
    cpy #@(++ (/ 256 screen_columns))
    lda #@(half (high screen))
    rol
    sta @(++ scr)
    and #1
    ora #>colors
    sta @(++ col)
    ldy scrx
    rts

clear_screen:
    0
    c_clrmw <screen >screen @(low 512) @(high 512)
    c_setmw <colors >colors @(low 512) @(high 512) @(+ multicolor white)
    0
    rts

init_screen:
    ; Clear character 0.
    ldx #7
    lda #0
l:  sta charset,x
    dex
    bpl -l

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
