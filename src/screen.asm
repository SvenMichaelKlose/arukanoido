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
