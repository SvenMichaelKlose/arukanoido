; Preshift sprite graphics for a sprite.
;
; A: Number of bits to shift.
; draw_sprites_tmp: Sprite dimensions (00YYYXXX)
;    X: width of X axis
;    Y: height of Y axis
; s: Graphics address
; d: Destination address
preshift_huge_sprite_one_offset:
    ; Configure the blitter.
    sta @(++ blit_left_addr)
    tay
    lda negate7,y
    sta @(++ blit_right_addr)

    ; Determine dimensions.
    lda draw_sprites_tmp
    tay
    and #%00000111
    sta sprite_cols
    tya
    and #%00111000
    sta sprite_lines

    ; Draw left half of sprite column.
l:  ldy sprite_lines
    dey
    jsr _blit_right_loop
    jsr step_to_next_column

    ; Check if we have to draw a right column.
    lda @(++ blit_left_addr)
    beq +n          ; No, not shifting…

    ldy sprite_lines
    dey
    jsr _blit_left_loop
    jsr step_to_next_column

n:  dec sprite_cols
    beq +done

    ; Step to next sprite graphics column.
n2: lda sprite_lines
    jsr add_sb
    jmp -l

step_to_next_column:
    lda sprite_lines
    jmp add_db

done:
    rts

; Preshift sprite graphics of a sprite for all offsets.
;
; Destination must be zeroed out beforehand.
;
; Will shift 4 times for multicoloured sprites and 8 times
; for hires ones.
;
; X: hires (0)/multicolor (not 0)
; Y: Sprite dimensions (lower octet is number of chars for X axis, next octet is Y axis)
; s: Sprite graphics
; d: Destination address
preshift_huge_sprite:
    sty draw_sprites_tmp
    stx draw_sprites_tmp2

    ldy #0
l:  lda s
    pha
    lda @(++ s)
    pha
    tya
    pha
    jsr preshift_huge_sprite_one_offset
    pla
    tay
    pla
    sta @(++ s)
    pla
    sta s

    iny
    lda draw_sprites_tmp2
    beq +n          ; Hires, step on a single bit.
    iny             ; Multicolor, step two bits.
n:  cpy #8
    bne -l
    rts
