sprites_nchars:    @(gen-sprite-nchars)

; Draw sprite, masking out the background
draw_huge_sprite:
    lda sprites_c,x
    sta curcol

    ;; Get screen position.
    txa
    asl
    tay
    lda spriteframe
    beq +n
    iny
n:  lda sprites_x,x
    sta sprite_x
    lsr
    lsr
    lsr
    sta sprite_scrx
    sta sprites_sx,y
    lda sprites_y,x
    sta sprite_y
    lsr
    lsr
    lsr
    sta sprite_scry
    sta sprites_sy,y

    ;; Get width.
    lda sprites_dimensions,x
    and #%111
    sta sprite_cols

    sta sprite_cols_on_screen
    lda sprite_x
    and #%111
    beq +n
    inc sprite_cols_on_screen     ; One more due to shift.
n:

    ;; Get height.
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
    dec sprite_lines
    sta sprite_lines_on_screen

    lda sprite_y
    and #%111
    beq +n
    inc sprite_rows_on_screen     ; One more due to shift.
    lda sprite_lines_on_screen
    clc
    adc #8
    sta sprite_lines_on_screen
n:

    ;; Save dimensions for clean-up.
    lda sprite_cols_on_screen
    sta sprites_sw,y
    lda sprite_rows_on_screen
    sta sprites_sh,y

    ;; Get char adress.
    ldy next_sprite_char
    sty sprite_char
    lda charset_addrs_l,y
    sta d
    sta tmp4
    lda charset_addrs_h,y
    sta @(++ d)
    sta tmp5

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

if @*show-cpu?*
    inc $900f
end

    ;; Copy existing graphics into allocated chars.
    lda sprite_cols_on_screen
    sta tmp3
    lda sprite_scrx
    sta scrx

l2: lda sprite_rows_on_screen
    sta tmp2
    lda sprite_scry
    sta scry

l:  ; Get screen address.
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)

    ldy scrx
    lda (scr),y
    beq +m
    tay

    ; DOH char? (Any frame.)
    and #background
    cmp #background
    beq +q      ; Yes. Copy…

    ; Char of current frame?
    tya
    beq +m
    and #framemask
    cmp spriteframe
    beq +q      ; Yes, Copy…

    ; DOH char to mix into?
    lda is_doh_level
    beq +m
    lda scr
    sta sl
    lda @(++ scr)
    ora bricks
    sta sh
    ldy scrx
    lda (s),y
    and #background
    cmp #background
    bne +m      ; No. Clear…
    lda (s),y   ; Copy DOH char.
    tay

    ; Get char address to copy from.
q:  lda charset_addrs_l,y
    sta sl
    lda charset_addrs_h,y
    sta sh

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

l2b:bne -l2     ; (jmp)
l3: bne -l      ; (jmp)

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
    lda dl
    clc
    adc #8
    sta dl
    bcc +n
    inc dh
n:  dec tmp2
    bne -l3

    inc scrx
    dec tmp3
    bne -l2b

    ;;; Draw sprite graphics into prepared chars.
    ;; Get destination address.
    lda sprite_y
    and #%111
    clc
    adc tmp4
    sta dl
    ldy tmp5
    bcc +n
    iny
n:  sty dh

if @*show-cpu?*
    inc $900f
end

    lda sprite_cols         ; (Loop init.)
    sta tmp2

    ;; Draw pre-shifted?
    lda sprites_pgh,x
    bne +l
    jmp slow_shift          ; No…
l:  sta sh
    lda sprites_pgl,x
    sta sl

    ; Make number of chars number of bytes.
    ldy sprites_dimensions,x
    lda sprites_nchars,y
    asl
    asl
    asl
    sec                 ; Add that extra column.
    adc sprite_lines
    sta tmp3

    ; Get number of times to shift.
    lda sprite_x
    and #%111
    beq +l2             ; No shift. Ready to draw…
    ldy curcol
    bpl +n
    lsr                 ; Half X resolution for multicolor.
n:  tay

    ; Subtract column bytes from total.
    lda sl
    clc
    sbc sprite_lines
    bcs +l4
    dec sh

    ; Multiply bytes by shifts.
l4: clc
    adc tmp3
    bcc +n3
    inc sh
n3: dey
    bne -l4
    sta sl

    lda sprite_cols_on_screen
    sta tmp2
    lda overkill
    bne turbo_preshift

    ;; Draw sprite column.
l2: ldy sprite_lines
l:  lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl -l

    dec tmp2
    beq +p

    ;; Step to next screen column.
    lda dl
    clc
    adc sprite_lines_on_screen
    sta dl
    bcc +n
    inc dh
n:

    ;; Step to next sprite column.
    lda sl
    sec
    adc sprite_lines
    sta sl
    bcc -l2
    inc sh
    bcs -l2     ; (jmp)

p:  jmp plot_chars

    ;; Draw sprite column.
turbo_preshift:
    dec overkill
l2: ldy sprite_lines
l:  lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    lda (s),y
    sta (d),y
    dey
    bpl -l

    dec tmp2
    beq +p

    ;; Step to next screen column.
    lda dl
    clc
    adc sprite_lines_on_screen
    sta dl
    bcc +n
    inc dh
n:

    ;; Step to next sprite column.
    lda sl
    sec
    adc sprite_lines
    sta sl
    bcc -l2
    inc sh
    bcs -l2     ; (jmp)

slow_shift:
    ;; Get sprite graphics.
    lda sprites_gl,x
    sta sl
    lda sprites_gh,x
    sta sh

    lda sprites_i,x
    and #is_bonus
    bne no_shift

    ;; Configure the blitter.
    lda sprite_x
    and #%111
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

    ;; Draw left half of sprite column.
l:  ldy sprite_lines
    jsr _blit_right_loop

    ;; Step to next screen column.
    lda dl
    clc
    adc sprite_lines_on_screen
    sta dl
    bcc +n
    inc dh
n:

    ;; Draw right half of sprite column.
    lda sprite_x
    and #%111
    beq +n      ; We might as well not if not shifted.
    ldy sprite_lines
    jsr _blit_left_loop
n:

    ;; Break here when all columns are done.
    dec tmp2
p:  beq +plot_chars

    ;; Step to next sprite graphics column.
    lda sl
    sec
    adc sprite_lines
    sta sl
    bcc -l
    inc sh
    bcs -l      ; (jmp)

no_shift:
    ;; Draw column.
l:  lda sprite_rows
    sta tmp3
    ldy #0
l2: lda (s),y
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
    iny
    dec tmp3
    bne -l2

    ;; Break here when all columns are done.
    dec tmp2
    beq plot_chars

    ;; Step to next screen column.
    lda dl
    clc
    adc sprite_lines_on_screen
    sta dl
    bcc +l
    inc dh
    bcs +l      ; (jmp)

    ;;; Plot the filled chars to screen.
plot_chars:
if @*show-cpu?*
    inc $900f
end
    ;; Get initial sprite char and screen position.
    lda sprite_char
    sta tmp

    ; Get screen and color RAM adresses.
    ldy sprite_scry
    lda sprite_scrx
    sta scrx
    clc
    adc line_addresses_l,y
    sta scr
    sta col
    lda line_addresses_h,y
    adc #0
    sta @(++ scr)
    ora #>colors
    sta @(++ col)
    lda #0
    sta tmp3

    ;; Do a column.
l2: lda sprite_scry
    sta scry
    lda sprite_rows_on_screen
    sta tmp2
    ldy tmp3

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
    ; Plot over background if DOH projectile.
    lda sprites_i,x
    and #is_doh_obstacle
    bne +l3
    lda (scr),y
    and #foreground
    bne +n                  ; Do not plot over background.

    ; Plot.
l3: lda tmp
    sta (scr),y
    lda curcol
    sta (col),y

    ; Next row.
n:  inc tmp     ; To next sprite char.
    inc scry
    lda next_line_offsets,y
    tay
    dec tmp2
    bne -l

    ; Next column.
    inc scrx
    inc tmp3
    dec sprite_cols_on_screen
    bne -l2

if @*show-cpu?*
    dec $900f
    dec $900f
    dec $900f
end
    rts

next_line_offsets:
    fill 128
