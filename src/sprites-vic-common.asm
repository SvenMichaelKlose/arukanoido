draw_sprites:
if @*show-cpu?*
    lda #@(+ 8 4)
    sta $900f
end

    ldx #0
l:  lda sprites_i,x
    bmi +n  ; Slot unused…
    sei
    jsr draw_huge_sprite
    cli
n:  inx
    cpx #num_sprites
    bne -l

if @*show-cpu?*
    lda #@(+ 8 1)
    sta $900f
end

    ldx #@(-- num_sprites)
sprites_clear_loop:
    sei

    ; Make frame-related index into sprite tables.
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

l2: ldy tmp
    lda sprites_sw,y
    tay

l3: lda (scr),y
    beq +n              ; Nothing to clear…
    and #foreground
    bne +n              ; Don't remove foreground chars…

    lda (scr),y
    and #framemask
    cmp spriteframe
    beq +n              ; Char belongs to sprite in current frame…

    lda is_doh_level
    beq +n2

    ; Make pointer into brick map.
    lda scr
    sta dl
    lda @(++ scr)
    ora bricks
    sta dh

    ; Check if DOH char
    lda (d),y
    and #background
    cmp #background
    bne +n2             ; No. Just clear…
    lda (d),y           ; Restore DOH char.
    bne +n3

n2: lda #0
n3: sta (scr),y

n:  dey
    bpl -l3

    ; Step to next screen line.
    lda scr
    clc
    adc screen_columns
    sta scr
    bcs +l
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

l:  inc @(++ scr)
    bne -n  ; (jmp)

clear_screen_of_sprites:
    ldx #0
l:  lda screen,x
    jsr +j
    sta screen,x
    lda @(+ 256 screen),x
    jsr +j
    sta @(+ 256 screen),x
    cpx #76
    bcs +n
    lda @(+ 512 screen),x
    jsr +j
    sta @(+ 512 screen),x
n:  dex
    bne -l
    rts

j:  tay
    and #foreground
    bne +n
    ; TODO: Restore DOH chars.
    ldy #0
n:  tya
    rts
