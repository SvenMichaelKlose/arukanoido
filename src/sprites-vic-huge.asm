sprites_nchars:    @(gen-sprite-nchars)

; Draw sprite, masking out the background
draw_huge_sprite:
    lda sprites_i,x
    cmp #is_vaus
    bne +n
    nop
n:
    ;; Get screen position.
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

    ;; Determine width.
    lda sprites_dimensions,x
    and #%111
    sta sprite_cols

    sta sprite_cols_on_screen
    lda sprites_x,x
    and #%111
    beq +n
    inc sprite_cols_on_screen     ; One more due to shift.
n:

    ;; Determine height.
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

    ;; Save dimensions for cleanup.
    lda sprite_cols_on_screen
    sta sprites_w,x
    lda sprite_rows_on_screen
    sta sprites_h,x

    ;; Get char adress.
    lda next_sprite_char
    sta sprite_char
    asl
    asl
    asl
    sta d
    pha
    lda sprite_char
    lsr
    lsr
    lsr
    lsr
    lsr
    clc
    adc #>charset
    sta @(++ d)
    pha

    ;; Allocate chars.
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

    ;; Copy existing graphics into allocated chars.
    lda sprite_cols_on_screen
    sta draw_sprites_tmp3
    lda sprite_x
    sta scrx

l2: lda sprite_rows_on_screen
    sta draw_sprites_tmp2
    lda sprite_y
    sta scry

l:  ; Get screen address.
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)

    ldy scrx
    lda (scr),y
    tay

    ; DOH char? (Any frame.)
    and #%01100000
    cmp #%01100000
    beq +q      ; Yes. Copy…

    ; Char of current frame?
    tya
    and #framemask
    cmp spriteframe
    beq +q      ; Yes, Copy…

    ; Not in our frame. Get pointer into brick map.
    lda scr
    sta s
    lda @(++ scr)
    ora #>bricks
    sta @(++ s)

    ; Usually a DOH char at this position?
    ldy scrx
    lda (s),y
    and #%01100000
    cmp #%01100000
    bne +m      ; No. Clear…
    lda (s),y   ; Copy DOH char.
    tay

    ; Get char address to copy from.
q:  tya
    asl
    asl
    asl
    sta s
    tya
    lsr
    lsr
    lsr
    lsr
    lsr
    clc
    adc #>charset
    sta @(++ s)

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
    bne +l3

    inc scrx
    dec draw_sprites_tmp3
    bne +l2b

    ;; Get destination address in charset.
    pla
    sta @(++ d)
    pla
    sta d

    ;; Add Y char offset.
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

    ;; Draw pre-shifted?
    lda sprites_pgh,x
    bne +l
    jmp slow_shift          ; No…

l3: jmp -l
l2b:jmp -l2

    ;; Draw pre-shifted graphics.
    ; Get sprite graphics.
l:  sta @(++ s)
    lda sprites_pgl,x
    sta s

    ; Make number of chars number of bytes.
    ldy sprites_dimensions,x
    lda sprites_nchars,y
    asl
    asl
    asl
    clc                 ; Add that extra column.
    adc sprite_lines
    sta draw_sprites_tmp3

    ; Get number of times to shift.
    lda sprites_x,x
    and #%111
    beq +l2             ; No shift. Ready to draw…
    ldy sprites_c,x
    bpl +n
    lsr                 ; Half X resolution for multicolor.
n:  tay

    ; Subtract column bytes from total.
    lda s
    sec
    sbc sprite_lines
    bcs +l4
    dec @(++ s)

    ; Multiply bytes by shifts.
l4: clc
    adc draw_sprites_tmp3
    bcc +n3
    inc @(++ s)
n3: dey
    bne -l4
    sta s

    lda sprite_cols_on_screen
    sta draw_sprites_tmp2

    ;; Draw sprite column.
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

    dec draw_sprites_tmp2
    beq plot_chars

    ;; Step to next screen column.
    lda d
    clc
    adc sprite_lines_on_screen
    sta d
    bcc +n
    inc @(++ d)
n:

    ;; Step to next sprite column.
    lda s
    clc
    adc sprite_lines
    sta s
    bcc +n
    inc @(++ s)
n:  jmp -l2

slow_shift:
    ;; Configure the blitter.
    lda sprites_x,x
    and #%111
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

    ;; Get sprite graphics.
    lda sprites_gl,x
    sta s
    lda sprites_gh,x
    sta @(++ s)

    ;; Draw left half of sprite column.
l:  ldy sprite_lines
    dey
    jsr _blit_right_loop

    ;; Step to next screen column.
    lda d
    clc
    adc sprite_lines_on_screen
    sta d
    bcc +n
    inc @(++ d)
n:

    ;; Draw right half of sprite column.
    lda sprites_x,x
    and #%111
    beq +n      ; We might as well not if not shifted.
    ldy sprite_lines
    dey
    jsr _blit_left_loop
n:

    ;; Break here when all columns are done.
    dec draw_sprites_tmp2
    beq +plot_chars

    ;; Step to next sprite graphics column.
    lda s
    clc
    adc sprite_lines
    sta s
    bcc -l
    inc @(++ s)
    jmp -l

    ;;; Plot the filled chars to screen.
plot_chars:
    ;; Get initial sprite char and screen position.
    lda sprite_char
    sta draw_sprites_tmp
    lda sprite_x
    sta scrx

    ;; Do a column.
l2: lda sprite_y
    sta scry
    lda sprite_rows_on_screen
    sta draw_sprites_tmp2

l:  ;; Check if position is plottable.
    lda scry
    cmp playfield_yc
    bcc +n                  ; Don't plot into score area…
    cmp screen_rows
    bcs +n                  ; Don't plot over the bottom…
    lda scrx
    cmp #playfield_columns
    bcs +n                  ; Don't plot over the right…

    ;; Check if on a background char.
    ; Get screen and color RAM adresses.
    ldy scry
    lda line_addresses_l,y
    sta scr
    sta col
    lda line_addresses_h,y
    sta @(++ scr)
    ora #>colors
    sta @(++ col)
    ldy scrx

    ; Plot over background if DOH projectile.
    lda sprites_i,x
    and #is_doh_obstacle
    bne +l3

    ; Check on background.
    lda (scr),y
    and #foreground
    bne +n                  ; Do not plot over background.

    ; Plot.
l3: lda draw_sprites_tmp
    sta (scr),y
    lda sprites_c,x
    sta (col),y

    ;;
n:  inc draw_sprites_tmp    ; To next sprite char.
    inc scry                ; To next row.
    dec draw_sprites_tmp2
    bne -l                  ; Next row…

    inc scrx
    dec sprite_cols_on_screen
    bne -l2                 ; Next column.

    rts
