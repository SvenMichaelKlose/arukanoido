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

    ; Determine width.
    lda sprites_dimensions,x
    and #%111
    sta sprite_cols
    sta sprite_cols_on_screen

    lda sprites_x,x
    and #%111
    beq +n
    inc sprite_cols_on_screen     ; One more due to shift.
n:

    ; Determine height.
    lda sprites_dimensions,x
    lsr
    lsr
    lsr
    sta sprite_rows
    sta sprite_rows_on_screen
    asl
    asl
    asl
    sta sprite_lines
    sta sprite_lines_on_screen

    lda sprites_y,x
    and #%111
    beq +n
    inc sprite_rows_on_screen     ; One more due to shift.
    lda sprite_lines_on_screen
    clc
    adc #8
    sta sprite_lines_on_screen
n:

    ; Save dimensions for cleanup.
    lda sprite_cols_on_screen
    sta sprites_w,x
    lda sprite_rows_on_screen
    sta sprites_h,x

    ; Allocate chars.
    lda next_sprite_char
l:  sta sprite_char
    jsr get_char_addr
    lda sprite_rows_on_screen
    asl
    asl
    asl
    ora sprite_cols_on_screen
    tay
    lda sprites_nchars,y
    clc
    adc next_sprite_char
    sta next_sprite_char
    and #foreground
    cmp #foreground                                                                                          
    bne +n
    lda spriteframe
    ora #first_sprite_char
    sta next_sprite_char
    jmp -l
n:

    ; Copy background graphics into allocated chars.
    lda sprite_cols_on_screen
    sta draw_sprites_tmp3
    lda sprite_x
    sta scrx

l2: lda sprite_rows_on_screen
    sta draw_sprites_tmp2
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
n:  dec draw_sprites_tmp2
    bne -l

    inc scrx
    dec draw_sprites_tmp3
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
    lda sprites_gl,x
    sta s
    lda sprites_gh,x
    sta @(++ s)

    lda sprite_cols
    sta draw_sprites_tmp2

    ; Draw left half of sprite column.
l:  ldy sprite_lines
    dey
    jsr _blit_right_loop

    ; Step to next screen column.
    lda d
    clc
    adc sprite_lines_on_screen
    sta d
    bcc +n
    inc @(++ d)
n:

    ; Draw right half of sprite column.
    lda sprites_x,x
    and #%111
    beq +n
    ldy sprite_lines
    dey
    jsr _blit_left_loop
n:

    ; Break here when all columns are done.
    dec draw_sprites_tmp2
    beq +plot_chars

    ; Step to next sprite graphics column.
    lda s
    clc
    adc sprite_lines
    sta s
    bcc -l
    inc @(++ s)
    jmp -l

    ; Plot the filled chars to screen.
plot_chars:
    lda sprite_char
    sta draw_sprites_tmp
    lda sprite_x
    sta scrx

l2: lda sprite_y
    sta scry
    lda sprite_rows_on_screen
    sta draw_sprites_tmp2

l:  lda scry
    cmp #playfield_yc
    bcc +n               ; Don't plot into score area…
    cmp screen_rows
    bcs +n               ; Don't plot over the bottom…
    lda scrx
    cmp #15
    bcs +n               ; Don't plot over the right…
    jsr scrcoladdr
    lda (scr),y
    and #foreground
    cmp #foreground
    beq +n
    lda draw_sprites_tmp
    sta (scr),y
    lda sprites_c,x
    sta (col),y
n:  inc draw_sprites_tmp
    inc scry
    dec draw_sprites_tmp2
    bne -l

    inc scrx
    dec sprite_cols_on_screen
    bne -l2

    rts
