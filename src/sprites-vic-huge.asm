sprites_nchars:    @(gen-sprite-nchars)

; Draw sprite, masking out the background
draw_huge_sprite:

    ;;;;;;;;;;;;;;;;;
    ;;; Configure ;;;
    ;;;;;;;;;;;;;;;;;

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

; #########################################################

    ;;;;;;;;;;;;;;;;;;;;;;
    ;;; Allocate chars ;;;
    ;;;;;;;;;;;;;;;;;;;;;;

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

; #########################################################

    ;;;;;;;;;;;;;;;;;;
    ;;; Init chars ;;;
    ;;;;;;;;;;;;;;;;;;

    ;; Copy existing graphics into allocated chars.
    lda sprite_cols_on_screen
    sta tmp3
    lda sprite_scrx
    sta scrx

init_next_row:
    lda sprite_rows_on_screen
    sta tmp2
    lda sprite_scry
    sta scry

init_next_char:
    ; Get screen address.
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)

    ldy scrx
    lda (scr),y
    beq init_clear
    tay

    ; DOH char? (Any frame.)
    and #background
    cmp #background
    beq init_copy   ; Yes. Copy…

    ; Char of current frame?
    tya
    beq init_clear
    and #framemask
    cmp spriteframe
    beq init_copy   ; Yes, Copy…

    ; DOH char to mix into?
    lda is_doh_level
    beq init_clear
    lda scr
    sta sl
    lda @(++ scr)
    ora bricks
    sta sh
    ldy scrx
    lda (s),y
    and #background
    cmp #background
    bne init_clear ; No. Clear…
    lda (s),y   ; Copy DOH char.
    tay

init_copy:
    ; Get char address to copy from.
    lda charset_addrs_l,y
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
    jmp init_done_char

j_init_next_char:
    bne init_next_char  ; (jmp)
j_init_next_row:
    bne init_next_row   ; (jmp)

init_clear:
    lda #0
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

init_done_char:
    inc scry
    lda dl
    clc
    adc #8
    sta dl
    bcc +n
    inc dh
n:  dec tmp2
    bne j_init_next_char

    inc scrx
    dec tmp3
    bne j_init_next_row

; #########################################################

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Draw sprite into chars ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

    ;; Get pre-shifted data.
    lda sprites_pgh,x
    bne +n
    jmp slow_shift          ; There is none…
n:  sta sh
    lda sprites_pgl,x
    sta sl

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; PRE-SHIFTED SPRITES ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    beq regular_column  ; No shift. Ready to draw…
    ldy curcol
    bpl +n
    lsr                 ; Half X resolution for multicolor.
n:  tay

    ; Subtract column bytes from total.
    lda sl
    clc
    sbc sprite_lines
    bcs multiply_by_shifts
    dec sh

    ; Multiply bytes by shifts.
multiply_by_shifts:
    clc
    adc tmp3
    bcc +n
    inc sh
n:  dey
    bne multiply_by_shifts
    sta sl

    lda sprite_cols_on_screen
    sta tmp2
    lda overkill
    bne turbo_preshift

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; REGULAR PRE-SHIFTED (OR) ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Draw sprite column.
regular_column:
    ldy sprite_lines
regular_char:
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
    lda (s),y
    ora (d),y
    sta (d),y
    dey
    bpl regular_char

    dec tmp2
    beq j2_plot_chars

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
    bcc regular_column
    inc sh
    bcs regular_column ; (jmp)

j2_plot_chars:
    jmp plot_chars

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; TURBO (PRE-SHIFTED COPY) ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Draw sprite column.
turbo_preshift:
    dec overkill
turbo_column:
    ldy sprite_lines
turbo_char:
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
    lda (s),y
    sta (d),y
    dey
    bpl turbo_char

    dec tmp2
    beq j_plot_chars

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
    bcc turbo_column
    inc sh
    bcs turbo_column ; (jmp)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; SLOW MANUALLY SHIFTED ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

slow_shift:
    ;; Get sprite graphics.
    lda sprites_gl,x
    sta sl
    lda sprites_gh,x
    sta sh

    lda sprites_i,x
    and #is_bonus
    bne direct_copy

    ;; Configure the blitter.
    lda sprite_x
    and #%111
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

slow_column:
    ;; Draw left half of sprite column.
    ldy sprite_lines
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
j_plot_chars:
    beq +plot_chars

    ;; Step to next sprite graphics column.
    lda sl
    sec
    adc sprite_lines
    sta sl
    bcc slow_column
    inc sh
    bcs slow_column ; (jmp)

    ;;;;;;;;;;;;;;;;;;;
    ;;; DIRECT COPY ;;;
    ;;;;;;;;;;;;;;;;;;;

    ;; Draw column.
direct_copy:
    lda sprite_rows
    sta tmp3
    ldy #0
direct_char:
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
    iny
    dec tmp3
    bne direct_char

    ;; Break here when all columns are done.
    dec tmp2
    beq plot_chars

    ;; Step to next screen column.
    lda dl
    clc
    adc sprite_lines_on_screen
    sta dl
    bcc direct_copy
    inc dh
    bcs direct_copy ; (jmp)

; #########################################################

    ;;;;;;;;;;;;;;;;;;
    ;;; Plot chars ;;;
    ;;;;;;;;;;;;;;;;;;

plot_chars:
if @*show-cpu?*
    inc $900f
end
    ;; Get initial sprite char and screen position.
    lda sprite_char
    sta tmp

    ; Get screen and color address.
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

    ; Reset column index.
    lda #0
    sta tmp3

plot_column:
    lda sprite_scry
    sta scry
    lda sprite_rows_on_screen
    sta tmp2
    ldy tmp3

plot_row:
    ;; Check if position is plottable.
    lda scry
    cmp playfield_yc
    bcc dont_plot       ; Don't plot over top…
    cmp screen_rows
    bcs dont_plot       ; Don't plot over bottom…
    lda scrx
    cmp #playfield_columns
    bcs dont_plot       ; Don't plot over right…

    ;; Check if on a background char.
    ; Plot over background if DOH projectile.
    lda sprites_i,x
    and #is_doh_obstacle
    bne +n
    lda (scr),y
    and #foreground
    bne dont_plot       ; Do not plot over background.

    ;; Plot.
    ; Do not overwrite priority chars.
n:  lda (scr),y
    eor spriteframe
    beq +n
    cmp #last_priority_char + 1
    bcc dont_plot

n:  lda tmp
    sta (scr),y
    lda curcol
    sta (col),y

dont_plot:
    inc scry
    inc tmp                 ; To next sprite char.
    lda next_line_offsets,y
    tay
    dec tmp2
    bne plot_row

    ;; Next column.
    inc scrx
    inc tmp3
    dec sprite_cols_on_screen
    bne plot_column

if @*show-cpu?*
    dec $900f
    dec $900f
    dec $900f
end
    rts

next_line_offsets:
    fill 128
