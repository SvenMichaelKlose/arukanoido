; Nice and fast but cannot handle hitting corners with
; space behind diagonally.

b_nw    = 0
b_n     = 1
b_ne    = 2
b_e     = 3
b_se    = 4
b_s     = 5
b_sw    = 6
b_w     = 7

make_reflection_tables:
    ; Clear all tables.
    0
    clrmw <asl6 >asl6 00 01
    clrmw <mod7asl3 >mod7asl3 00 01
    clrmw <mod7 >mod7 00 01
    clrmw <reflection_infp >reflection_infp 00 02
    0

    ; Table to convert direction to one of 8 ball directions.
    ldx #7
l:  ldy ball_directions,x
    dex
    bpl -l

    ldx #0
l:  txa
    and #%11
    sta mod7,x
    asl
    asl
    asl
    sta mod7asl3,x
    inx
    bne -l

    rts

reflection_sides:
    ; Top
    direction_ls    b_n     direction_dls
    direction_l     b_n     direction_dl
    direction_r     b_n     direction_dr
    direction_rs    b_n     direction_drs
    ; ...

    ; Bottom
    direction_dls   b_s     direction_ls
    direction_dl    b_s     direction_l
    direction_dr    b_s     direciton_r
    direction_drs   b_s     direciton_rs
    ; ...

    ; Left
    direction_dl    b_w     direction_dr
    direction_dls   b_w     direction_drs
    direction_ls    b_w     direction_rs
    direction_l     b_w     direction_r
    ; ...

    ; Right
    direction_r     b_e     direction_l
    direction_rs    b_e     direction_ls
    direction_drs   b_e     direction_dls
    direction_dr    b_e     direction_dl
    ; ...

reflection_corners:
    ; Top left corner
    direction_dl    b_w     direction_dr
    direction_dls   b_w     direction_drs
    direction_ls    b_w     direction_dls
    direction_l     b_nw    direction_dr
    direction_r     b_n     direction_dr
    direction_rs    b_n     direction_drs

    ; Top right corner
    direction_ls    b_n     direction_dls
    direction_l     b_n     direction_dl
    direction_r     b_ne    direction_dl
    direction_rs    b_e     direction_ls
    direction_drs   b_e     direction_dls
    direction_dr    b_e     direction_dl


    ; Bottom left corner
    direction_drs   b_s     direction_rs
    direction_dr    b_s     direction_r
    direction_dl    b_sw    direction_r
    direction_dls   b_w     directoin_ls
    direction_ls    b_w     direction_rs
    direction_l     b_w     direction_r

    ; Bottom right corner
    direction_r     b_e     direction_l
    direction_rs    b_e     direction_ls
    direction_drs   b_e     direction_rs
    direction_dr    b_se    direction_l
    direction_dl    b_s     direction_l
    direction_dls   b_s     direction_ls

fast_reflect:
    ; Get ball positino and direction.
    lda sprites_x,x
    sta ball_x
    lda sprites_y,x
    sta ball_y
    lda sprites_d,x

    ; Pack three direction bits and three position bits for
    ; each axis into a 9-bit index as in %dddyyyxxx.
    tax
    lda asl6,x
    ldy ypos
    ora mod7asl3,y
    ldy xpos
    ora mod7,y
    tay
    txa
    lsr
    lsr
    and #1
    ora #>reflection_info
    sta pagedptr+1

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

    @(+ 2 double_screen_width)
test_offsets:
    0 1 2
    @(+ 2 screen_width)
    @(+ 2 double_screen_width)
    @(+ 1 double_screen_width)
    double_screen_width
    screen_width
    0
