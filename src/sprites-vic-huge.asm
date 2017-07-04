sprites_nchars: @(gen-sprite-nchars)

; Draw sprite, masking out the background
draw_huge_sprite:
    ; Get screen position.
    lda sprites_x,x
    lsr
    lsr
    lsr
    sta sprite_x
    lda sprites_y,x
    lsr
    lsr
    lsr
    sta sprite_y

    ; Determine width and height in chars.
    lda sprites_dimensions,x
    and #%111
    sta sprite_cols
    sta sprite_inner_cols

    lda sprites_x,x
    and #%111
    beq +n
    inc sprite_cols
n:

    lda sprites_dimensions,x
    lsr
    lsr
    lsr
    sta sprite_rows
    sta sprite_inner_rows
    asl
    asl
    asl
    sta sprite_inner_lines
    sta sprite_lines

    lda sprites_y,x
    and #%111
    beq +n
    inc sprite_rows
    lda sprite_lines
    clc
    adc #8
    sta sprite_lines
n:

    ; Allocate chars.
    lda next_sprite_char
l:  sta sprite_char
    jsr get_char_addr
    lda sprite_rows
    asl
    asl
    asl
    ora sprite_cols
    tay
    lda sprites_nchars,y
    clc
    adc next_sprite_char
    sta next_sprite_char
    and #foreground
    cmp #foreground                                                                                          
    bne +n
stop:
    lda spriteframe
    ora #first_sprite_char
    sta next_sprite_char
    jmp -l
n:

    ; Copy background graphics into allocated chars.
    lda sprite_cols
    sta tmp3
    lda sprite_x
    sta scrx

l2: lda sprite_rows
    sta tmp2
    lda sprite_y
    sta scry

l:  jsr scraddr
    lda (scr),y
    tay
    and #framemask
    cmp spriteframe
    bne +m
    tya
    jsr get_char_addr_s
    jsr blit_char
    jmp +n
m:  jsr blit_clear_char
n:

    inc scry
    lda d
    clc
    adc #8
    sta d
    bcc +n
    inc @(++ d)
n:  dec tmp2
    bne -l

    inc scrx
    dec tmp3
    bne -l2

    ; Configure the blitter.
    lda sprites_x,x
    and #%111
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

    ; Get sprite charset address.
    lda sprite_char
    jsr get_char_addr
    lda sprites_y,x
    and #%111
    clc
    adc d
    sta d
    bcc +n
    inc @(++ d)
n:

    ; Get sprite graphics.
    lda sprites_l,x
    sta s
;    lda sprites_gfx_h,x
    lda #>sprite_gfx
    sta @(++ s)

    lda sprite_inner_cols
    sta tmp2

    ; Draw left half of sprite column.
l:  ldy sprite_inner_lines
    dey
    jsr _blit_right_loop

    ; Step to next screen column.
    lda d
    clc
    adc sprite_lines
    sta d
    bcc +n
    inc @(++ d)
n:

    ; Draw right half of sprite column.
    lda sprites_x,x
    and #%111
    beq +n
    ldy sprite_inner_lines
    dey
    jsr _blit_left_loop
n:

    ; Break here when all columns are done.
    dec tmp2
    beq +plot_chars

    ; Step to next sprite graphics column.
    lda s
    clc
    adc sprite_inner_lines
    sta s
    bcc -l
    inc @(++ s)
    jmp -l

    ; Plot the filled chars to screen.
plot_chars:
    lda sprite_char
    sta tmp
    lda sprite_x
    sta scrx

l2: lda sprite_y
    sta scry
    lda sprite_rows
    sta tmp2

l:  jsr scrcoladdr
    lda (scr),y
    and #foreground
    cmp #foreground
    beq +n
    lda tmp
    sta (scr),y
    lda sprites_c,x
    sta (col),y
n:  inc tmp
    inc scry
    dec tmp2
    bne -l

    inc scrx
    dec sprite_cols
    bne -l2

    rts
