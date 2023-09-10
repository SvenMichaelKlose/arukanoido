mod7asl3        = $9800
mod7            = $9900
reflection_info = $9a00
asl6            = $9c00

; 3x3 char offset table indexes.
b_nw    = 0
b_n     = 1
b_ne    = 2
b_e     = 3
b_se    = 4
b_s     = 5
b_sw    = 6
b_w     = 7

; Indexes into 'used_ball_directions'.
di_ls   = 0
di_l    = 1
di_r    = 2
di_rs   = 3
di_drs  = 4
di_dr   = 5
di_dl   = 6
di_dls  = 7

make_reflection_tables:
    ; Clear all tables.
    0
    clrmw <asl6 >asl6 00 01
    clrmw <mod7asl3 >mod7asl3 00 01
    clrmw <mod7 >mod7 00 01
    0

    ; Table to convert direction to one of 8 ball directions.
    ldx #7
l:  txa
    asl
    asl
    asl
    asl
    asl
    asl
    sta asl6,x
    dex
    bpl -l

    ; Shift/modulo tables.
    ldx #0
l:  txa
    and #%111
    sta mod7,x
    asl
    asl
    asl
    sta mod7asl3,x
    lda #$ff
    sta reflection_info,x
    sta @(+ reflection_info 256),x
    inx
    bne -l

    lda #<reflection_corners
    sta s
    lda #>reflection_corners
    sta @(++ s)

    lda #0
    sta ball_x
    sta ball_y
    ldx #6
    jsr make_spots
    lda #7
    sta ball_x
    ldx #6
    jsr make_spots
    lda #7
    sta ball_y
    ldx #6
    jsr make_spots
    lda #0
    sta ball_x
    ldx #6
    jsr make_spots


    ldx #6
l:  stx ball_x
    txa
    pha

    lda #<reflection_top
    sta s
    lda #>reflection_top
    sta @(++ s)
    lda #0
    sta ball_y
    ldx #4
    jsr make_spots

    lda #<reflection_bottom
    sta s
    lda #>reflection_bottom
    sta @(++ s)
    lda #7
    sta ball_y
    ldx #4
    jsr make_spots

    pla
    sta ball_y
    pha

    lda #<reflection_left
    sta s
    lda #>reflection_left
    sta @(++ s)
    lda #0
    sta ball_x
    ldx #4
    jsr make_spots

    lda #<reflection_right
    sta s
    lda #>reflection_right
    sta @(++ s)
    lda #7
    sta ball_x
    ldx #4
    jsr make_spots

    pla
    tax
    dex
    bne -l

    ; Char offsets
    lda #<test_offsets
    sta d
    lda #>test_offsets
    sta @(++ d)
    lda #0
    jsr out_d
    lda #1
    jsr out_d
    lda #2
    jsr out_d
    lda screen_columns
    jsr out_d
    lda screen_columns
    clc
    adc #2
    jsr out_d
    lda screen_columns
    asl
    sta @(-- test_offsets)
    jsr out_d
    clc
    adc #1
    jsr out_d
    clc
    adc #1
    jsr out_d
    lda #0
    jsr out_d

    rts

make_spots:
    txa
    pha
    tya
    pha
    lda ball_y
    pha
    asl ball_y
    asl ball_y
    asl ball_y
l:  jsr make_spot
    dex
    bne -l
    pla
    sta ball_y
    pla
    tay
    pla
    tax
    rts

make_spot:
    ; Fetch direction index and save its MSB to 'tmp'.
    ldy #0
    lda (s),y
    lsr
    lsr
    sta tmp

    ; Fetch it again and shift the other two bits to bits 6 and 7.
    lda (s),y
    jsr inc_s
    asl
    asl
    asl
    asl
    asl
    asl

    ; Add the mod7 coordinates.
    ora ball_y
    ora ball_x

    ; Take those 9 bits and make them an index into reflection_info.
    clc
    adc #<reflection_info
    sta c
    lda #>reflection_info
    adc tmp
    sta @(++ c)
    lda (s),y
    jsr inc_s
    sta (c),y
    rts

inc_s:
    inc s
    bne +n
    inc @(++ s)
n:  rts

out_d:
    ldy #0
    sta (d),y

inc_d:
    inc d
    bne +n
    inc @(++ d)
n:  rts

reflection_top:
    di_ls    @(+ b_n     (* 8 di_dls))
    di_l     @(+ b_n     (* 8 di_dl))
    di_r     @(+ b_n     (* 8 di_dr))
    di_rs    @(+ b_n     (* 8 di_drs))

reflection_bottom:
    di_dls   @(+ b_s     (* 8 di_ls))
    di_dl    @(+ b_s     (* 8 di_l))
    di_dr    @(+ b_s     (* 8 di_r))
    di_drs   @(+ b_s     (* 8 di_rs))

reflection_left:
    di_dl    @(+ b_w     (* 8 di_dr))
    di_dls   @(+ b_w     (* 8 di_drs))
    di_ls    @(+ b_w     (* 8 di_rs))
    di_l     @(+ b_w     (* 8 di_r))

reflection_right:
    di_r     @(+ b_e     (* 8 di_l))
    di_rs    @(+ b_e     (* 8 di_ls))
    di_drs   @(+ b_e     (* 8 di_dls))
    di_dr    @(+ b_e     (* 8 di_dl))

reflection_corners:
    ; Top left corner
    di_dl    @(+ b_w     (* 8 di_dr))
    di_dls   @(+ b_w     (* 8 di_drs))
    di_ls    @(+ b_w     (* 8 di_dls))
    di_l     @(+ b_nw    (* 8 di_dr))
    di_r     @(+ b_n     (* 8 di_dr))
    di_rs    @(+ b_n     (* 8 di_drs))

    ; Top right corner
    di_ls    @(+ b_n     (* 8 di_dls))
    di_l     @(+ b_n     (* 8 di_dl))
    di_r     @(+ b_ne    (* 8 di_dl))
    di_rs    @(+ b_e     (* 8 di_ls))
    di_drs   @(+ b_e     (* 8 di_dls))
    di_dr    @(+ b_e     (* 8 di_dl))

    ; Bottom right corner
    di_r     @(+ b_e     (* 8 di_l))
    di_rs    @(+ b_e     (* 8 di_ls))
    di_drs   @(+ b_e     (* 8 di_rs))
    di_dr    @(+ b_se    (* 8 di_l))
    di_dl    @(+ b_s     (* 8 di_l))
    di_dls   @(+ b_s     (* 8 di_ls))

    ; Bottom left corner
    di_drs   @(+ b_s     (* 8 di_rs))
    di_dr    @(+ b_s     (* 8 di_r))
    di_dl    @(+ b_sw    (* 8 di_r))
    di_dls   @(+ b_w     (* 8 di_ls))
    di_ls    @(+ b_w     (* 8 di_rs))
    di_l     @(+ b_w     (* 8 di_r))

fast_reflect:
    ; Get ball positino and direction.
    lda sprites_x,x
    sta ball_x
    lda sprites_y,x
    sta ball_y
    lda sprites_d,x
    jsr get_used_ball_direction
    tya

    ; Pack three direction bits and three position bits for
    ; each axis into a 9-bit index as in %dddyyyxxx.
    tax
    lda asl6,x
    ldy ball_y
    ora mod7asl3,y
    ldy ball_x
    ora mod7,y
    tay
    txa
    lsr
    lsr
    and #1
    ora #>reflection_info
    sta @(++ pagedptr)

    ; Fetch reflection info from table.  Each byte is the
    ; new direction and a number telling which sides or
    ; corners of the current char have to be tested for
    ; bricks.
    lda (pagedptr),y
    bmi +done           ; Nothing to be done…

    ; Save new direction just in case.
    tax
    and #7
    sta new_direction

    ; Get top left corner's screen address.
    lda ball_x
    lsr
    lsr
    lsr
    sta scrx
    dec scrx
    lda ball_y
    lsr
    lsr
    lsr
    tay
    dey
    lda line_addresses_l,y
    clc
    adc scrx
    sta scr
    lda line_addresses_h,y
    adc #0
    sta @(++ scr)

    ; Get offset of the char to test.
    ldy test_offsets,x

    ; Test the char.
    lda (scr),y
    and #foreground
    beq +n
done:
    rts

    ; Check if we're into a corner.
n:  txa
    and #1
    beq -done   ; Not a corner…
    ldy @(- test_offsets 1),x
    lda (scr),y
    and #foreground
    beq -done   ; Fly by…
    ldy @(+ test_offsets 1),x
    lda (scr),y
    and #foreground
    rts
