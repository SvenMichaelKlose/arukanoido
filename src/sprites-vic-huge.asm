sprites_nchars:    @(gen-sprite-nchars)
preshift_indexes:  @(gen-preshift-indexes)

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
    sta sprite_char
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

    ; Copy existing graphics into allocated chars.
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
    ldy #0
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    iny
    lda (s),y
    sta (d),y
    jmp +n

m:  lda #0
    tay
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y
    iny
    sta (d),y

n:  inc scry
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

    ; Get destination address in charset.
    lda sprite_char
    jsr get_char_addr
    ; Add Y char offset.
    lda sprites_y,x
    and #%111
    clc
    adc d
    sta d
    bcc +n
    inc @(++ d)
n:

    lda sprite_cols
    sta draw_sprites_tmp2

    ; Draw pre-shifted?
    lda sprites_pgh,x
    bne +l
    jmp slow_shift          ; No…

    ;; Draw pre-shifted graphics.
    ; Get sprite graphics.
l:  sta @(++ s)
    lda sprites_pgl,x
    sta s
    lda sprites_x,x
    and #%111
    ldy sprites_c,x
    bpl +n
    lsr     ; Half X resolution for multicolor.
n:  asl
    asl
    asl
    ora sprite_rows
    tay
    lda preshift_indexes,y
    adc s
    sta s
    bcc +l2
    inc @(++ s)

    ; Draw left sprite column.
l2: lda sprite_rows
    sta draw_sprites_tmp3
    ldy #0
l:  lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    dec draw_sprites_tmp3
    bne -l

    ; Step to next screen column.
    lda d
    clc
    adc sprite_lines_on_screen
    sta d
    bcc +n
    inc @(++ d)
n:

    ; Step to next sprite column.
    lda s
    clc
    adc sprite_lines
    sta s
    bcc +n
    inc @(++ s)
n:

    ; Skip right column if not shifted.
    lda sprites_x,x
    and #%111
    beq +n2

    ; Draw right sprite column.
    lda sprite_rows
    sta draw_sprites_tmp3
    ldy #0
l:  lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    lda (s),y
    ora (d),y
    sta (d),y
    iny
    dec draw_sprites_tmp3
    bne -l

    ; Step to next sprite column.
    lda s
    clc
    adc sprite_lines
    sta s
    bcc +n
    inc @(++ s)
n:

n2:
    dec draw_sprites_tmp2
    beq +l3
    jmp -l2

l3: jmp +plot_chars

slow_shift:
    ; Configure the blitter.
    lda sprites_x,x
    and #%111
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

    ; Get sprite graphics.
    lda sprites_gl,x
    sta s
    lda sprites_gh,x
    sta @(++ s)

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
    cmp playfield_yc
    bcc +n               ; Don't plot into score area…
    cmp screen_rows
    bcs +n               ; Don't plot over the bottom…
    lda scrx
    cmp #playfield_columns
    bcs +n               ; Don't plot over the right…
    jsr scrcoladdr
    lda (scr),y
    and #foreground
    bne +n
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
