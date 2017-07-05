draw_sprites:
    ldx #@(-- num_sprites)
l:  sei
if @*show-cpu?*
    lda #@(+ 8 4)
    sta $900f
end
    lda sprites_i,x
    bmi +n

    lda #0
    sta foreground_collision
    jsr draw_huge_sprite
    lda sprites_i,x
    ora foreground_collision
    sta sprites_i,x

n:  cmp #@(+ is_inactive was_cleared)
    beq +n

if @*show-cpu?*
    lda #@(+ 8 1)
    sta $900f
end
 
    ; Remove remaining chars of sprites in old frame.
    lda sprites_ox,x
    sta scrx
l2: lda sprites_oy,x
    sta scry
    lda sprite_rows
    sta tmp2

l3: jsr scraddr_clear_char
    inc scry
    dec tmp2
    bpl -l3

    inc scrx
    dec sprite_cols
    bpl -l2

    ; Save current position as old one.
    jsr xpixel_to_char
    sta sprites_ox,x
    lda sprites_y,x
    jsr pixel_to_char
    sta sprites_oy,x

    lda sprites_i,x
    ora #was_cleared
    sta sprites_i,x

n:
if @*show-cpu?*
    lda #@(+ 8 2)
    sta $900f
end
    cli

    dex
    bpl -l
    rts

xpixel_to_char:
    lda sprites_x,x
pixel_to_char:
    lsr
    lsr
    lsr
    rts

clear_sprites:
    ldx #0
l:  lda screen,x
    and #foreground
    bne +n
    lda #0
    sta screen,x
n:  lda @(+ 258 screen),x
    and #foreground
    bne +n
    lda #0
    sta @(+ 258 screen),x
n:  dex
    bne -l
    rts
