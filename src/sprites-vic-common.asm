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
n:

    cmp #@(+ is_inactive was_cleared)
    beq +n

if @*show-cpu?*
    lda #@(+ 8 1)
    sta $900f
end

    ; Remove remaining chars of sprites in old frame.
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

    ; Save current position as old one.
    lda sprites_x,x
    lsr
    lsr
    lsr
    sta sprites_ox,x
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta sprites_oy,x
    lda sprites_w,x
    sta sprites_ow,x
    lda sprites_h,x
    sta sprites_oh,x

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
