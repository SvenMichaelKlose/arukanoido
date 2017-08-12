draw_sprites:
    ldx #@(-- num_sprites)
l:  sei

if @*show-cpu?*
    lda #@(+ 8 4)
    sta $900f
end

    lda sprites_i,x
    bmi +n
    and #was_cleared
    beq +n

    lda #0  ; TODO: Remove.
    sta foreground_collision
    jsr draw_huge_sprite
    lda sprites_i,x
    ora foreground_collision    ; TODO: Remove.
    and #@(bit-xor 255 was_cleared)
    sta sprites_i,x

    ; Save virtual position as screen position.
    lda sprites_x,x
    sta sprites_sx,x
    lda sprites_y,x
    sta sprites_sy,x
    lda sprites_w,x
    sta sprites_sw,x
    lda sprites_h,x
    sta sprites_sh,x
    lda spriteframe
    sta sprites_sf,x

n:  cli
    dex
    bpl -l

if @*show-cpu?*
    lda #@(+ 8 1)
    sta $900f
end

    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    and #was_cleared
    bne +n

    sei

    ; Remove remaining chars of sprites in old frame.
    lda spriteframe
    pha
    lda sprites_of,x
    eor #framemask
    sta spriteframe
    lda sprites_ox,x
    sta scrx
    lda sprites_ow,x
    sta sprite_cols
l2: lda sprites_oy,x
    sta scry
    lda sprites_oh,x
    sta sprite_rows
l3: jsr scraddr_clear_char
    inc scry
    dec sprite_rows
    bpl -l3
    inc scrx
    dec sprite_cols
    bpl -l2
    pla
    sta spriteframe

    ; Save screen position as the next one to clean.
    lda sprites_sx,x
    lsr
    lsr
    lsr
    sta sprites_ox,x
    lda sprites_sy,x
    lsr
    lsr
    lsr
    sta sprites_oy,x
    lda sprites_sw,x
    sta sprites_ow,x
    lda sprites_sh,x
    sta sprites_oh,x
    lda sprites_sf,x
    sta sprites_of,x

    lda sprites_i,x
    ora #was_cleared
    sta sprites_i,x

n:  cli
    dex
    bpl -l

if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end

    rts

clear_sprites:
    ldx #0
l:  lda screen,x
    and #foreground
    cmp #foreground
    beq +n
    lda #0
    sta screen,x
n:  lda @(+ 258 screen),x
    and #foreground
    cmp #foreground
    beq +n
    lda #0
    sta @(+ 258 screen),x
n:  dex
    bne -l
    rts
