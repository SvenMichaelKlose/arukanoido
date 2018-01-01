draw_sprites:
    ldx #@(-- num_sprites)
l:  sei

if @*show-cpu?*
    lda #@(+ 8 4)
    sta $900f
end

    lda sprites_i,x
    bmi +next

    jsr draw_huge_sprite

    ; Save position of drawn sprite.
    txa
    asl
    tay
    lda spriteframe
    beq +n
    iny
n:  lda sprites_x,x
    lsr
    lsr
    lsr
    sta sprites_sx,y
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta sprites_sy,y
    lda sprites_w,x
    sec
    sbc #1
    sta sprites_sw,y
    lda sprites_h,x
    sta sprites_sh,y

next:
    cli
    dex
    bpl -l

if @*show-cpu?*
    lda #@(+ 8 1)
    sta $900f
end

    ldx #@(-- num_sprites)
sprites_clear_loop:
    lda sprites_i,x

    sei

    txa
    asl
    tay
    lda spriteframe
    bne +n
    iny
n:  sty tmp

    ; Prepare 2-dimensional loop and address on screen.
    lda sprites_sh,y
    beq +not_dirty
    sta sprite_rows
    lda #0
    sta sprites_sh,y

    lda sprites_sy,y
    sta tmp2
    lda sprites_sx,y
    clc
    ldy tmp2
    adc line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    adc #0
    sta @(++ scr)

l2: lda scr
    pha
    lda @(++ scr)
    pha
    ldy tmp
    lda sprites_sw,y
    tay

l3: lda (scr),y
    beq +n              ; Nothing to clear…
    and #foreground
    bne +n              ; Don't remove foreground chars…
    lda (scr),y
    and #framemask
    cmp spriteframe
    beq +n
    lda #0
    sta (scr),y

n:  dey
    bpl -l3

    ; Step to next screen line.
    pla
    sta @(++ scr)
    pla
    clc
    adc screen_columns
    sta scr
    bcc +n
    inc @(++ scr)
    
n:  dec sprite_rows
    bne -l2

not_dirty:
    cli
    dex
    bpl sprites_clear_loop

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
