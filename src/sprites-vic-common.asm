draw_sprites:
if @*show-cpu?*
    lda #@(+ 8 4)
    sta $900f
end

    ldx #@(-- num_sprites)
l:  lda sprites_i,x
    bmi +next

    sei
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

    cli
;if @*has-digis?*
;    jsr exm_work
;end

next:
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
    beq +n      ; Char belongs to sprite in current frame…

    ; Make pointer into brick map.
    lda scr
    sta dl
    lda @(++ scr)
    ora bricks
    sta dh

    ; Check if DOH char
    lda (d),y
    and #%01100000
    cmp #%01100000
    bne +n2     ; No. Just clear…
    lda (d),y   ; Restore DOH char.
    jmp +n3

n2: lda #0
n3: sta (scr),y

n:  dey
    bpl -l3

    ; Step to next screen line.
    lda scr
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
