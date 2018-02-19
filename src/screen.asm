; Calculate line address in screen.
scraddr:
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)
    ldy scrx
    rts

scrcoladdr:
    ldy scry
    lda line_addresses_l,y
    sta scr
    sta col
    lda line_addresses_h,y
    sta @(++ scr)
    ora #>colors
    sta @(++ col)
    ldy scrx
    rts

plot:
    sta scrx
    sty scry
plot_scr:
    jsr scrcoladdr
    lda curchar
    sta (scr),y
    lda curcol
    sta (col),y
    rts

plot_char:
    pha
    jsr scrcoladdr
    pla
    sta (scr),y
    pha
    lda curcol
    sta (col),y
    pla
    rts

clear_screen:
    0
    clrmw <screen >screen @(low 588) @(high 588)
    setmw <colors >colors @(low 588) @(high 588) @(+ multicolor white)
    0
    rts

init_screen:
    ; Clear character 0.
    ldx #7
    lda #0
l:  sta charset,x
    dex
    bpl -l

    lda user_screen_origin_x
    sta $9000
    lda user_screen_origin_y
    sta $9001

    lda screen_columns
    sta $9002
    lda screen_rows
    asl
    sta $9003

    lda #@(+ vic_screen_1000 vic_charset_1400)
    sta $9005
    lda #@(+ reverse red)   ; Screen and border color.
    sta $900f

reset_volume:
    lda #@(* light_cyan 16) ; Auxiliary color.
    sta $900e
    rts
