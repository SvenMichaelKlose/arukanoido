; Preshift sprite graphics for a single sprite.
;
; Destination must be zeroed out beforehand which is much
; snappier if this routine does not have to do it but you
; do it in one run for all graphics.
;
; A: Number of bits to shift.
; X: Sprite index
; d: Destination address
preshift_huge_sprite:
    ; Determine width.
    pha
    lda sprites_dimensions,x
    and #%111
    sta sprite_cols
    sta sprite_cols_on_screen

    pla
    pha
    cmp #0
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

    ; Configure the blitter.
    pla
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

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

    jsr step_to_next_column

    ; Draw right half of sprite column.
    lda sprites_x,x
    and #%111
    beq +n
    ldy sprite_lines
    dey
    jsr _blit_left_loop
n:

    ; Break here when all columns are done…
    dec draw_sprites_tmp2
    beq +step_to_next_column

    ; Step to next sprite graphics column.
    lda s
    clc
    adc sprite_lines
    sta s
    bcc -l
    inc @(++ s)
    jmp -l

step_to_next_column:
    lda d
    clc
    adc sprite_lines_on_screen
    sta d
    bcc +n
    inc @(++ d)
n:  rts
