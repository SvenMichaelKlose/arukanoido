; Reuse char already allocated by another sprite.
reuse_char:
    lda curcol
    ldy scrx
    sta (col),y
    txa
    sta curchar

; Get address of character in charset.
get_char_addr:
    tay
    lda charset_addrs_l,y
    sta d
    lda charset_addrs_h,y
    sta @(++ d)
    rts

; Get address of character in charset.
get_char_addr_s:
    tay
    lda charset_addrs_l,y
    sta s
    lda charset_addrs_h,y
    sta @(++ s)
    rts

; We've run out of chars. Reset allocation.
alloc_wrap:
    lda spriteframe
    ora #first_sprite_char
    jmp fetch_char

alloc_char:
    lda next_sprite_char
    and #foreground
    bne alloc_wrap      ; No chars left…
    lda next_sprite_char
    inc next_sprite_char

fetch_char:
    pha
    jsr get_char_addr
    jsr blit_clear_char
    pla
    iny
    rts

; Out:
;   CC: ok, Y: X position
;   CS: illegal position
test_position:
    lda scry
    cmp screen_rows
    bcs +l
    lda scrx
    cmp screen_columns
    tay
l:  rts

scraddr_get_char:
    jsr scrcoladdr

get_char:
    jsr test_position
    bcs cant_use_position
    lda (scr),y
    beq +l              ; Screen char isn't used, yet…
    tax
    and #foreground
    bne on_foreground   ; Can't draw on foreground…
    txa
    and #framemask
    cmp spriteframe
    beq reuse_char      ; Already used by a sprite in current frame…
l:  jsr alloc_char
    sta curchar
    rts

set_char:
    php
    tya
    pha
    lda curchar
    beq +n
    ldy scrx
    sta (scr),y
    lda curcol
    sta (col),y
n:  pla
    tay
    plp
    rts

on_foreground:
cant_use_position:
    lda #$f0            ; Draw into ROM.
    sta @(++ d)
    lda #0
    sta curchar
    rts

clear_char:
    lda (scr),y
    beq +l              ; Nothing to clear…
    and #foreground
    bne +l              ; Don't remove foreground chars…
    lda (scr),y
    and #framemask
    cmp spriteframe
    beq +l              ; Current frame…
    lda #0
    sta (scr),y
l:  rts

clear_charset:
    0
    clrmw <charset >charset $00 $08
    0
    rts
