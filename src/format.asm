set_format:
    lda is_landscape
    bne set_format_landscape

set_format_portrait:
    lda #15
    sta screen_columns
    lda #32
    sta screen_rows
    lda #@(* 29 8)
    sta vaus_y
    lda #2
    sta playfield_yc
    lda #10
    sta txt_hiscore_x
    lda #0
    sta txt_hiscore_y
    lda #12
    sta hiscore_x
    lda #1
    sta hiscore_y
    lda #0
    sta score_x
    lda #1
    sta score_y

    jmp set_format_common

set_format_landscape:
    lda #21
    sta screen_columns
    lda #28
    sta screen_rows
    lda #@(* 27 8)
    sta vaus_y
    lda #0
    sta playfield_yc
    lda #31
    sta txt_hiscore_x
    lda #2
    sta txt_hiscore_y
    lda #33
    sta hiscore_x
    lda #3
    sta hiscore_y
    lda #33
    sta score_x
    lda #1
    sta score_y

set_format_common:
    ; Make line addresses.
    lda #<screen
    sta s
    lda #>screen
    sta @(++ s)
    ldx #0
l:  lda s
    sta line_addresses_l,x
    lda @(++ s)
    sta line_addresses_h,x
    lda s
    clc
    adc screen_columns
    sta s
    bcc +n
    inc @(++ s)
n:  inx
    cpx screen_rows
    bcc -l
    beq -l          ; Invisible bottom line.

    ; Set default screen origin.
    lda is_ntsc
    beq +n
    ldx #12
    ldy #9
    lda is_Landscape
    beq +l
    ldx #5
    ldy #16
    jmp +l
n:  ldx #20
    ldy #21
    lda is_Landscape
    beq +l
    ldx #$0d
    ldy #$1b
    jmp +l
l:  stx user_screen_origin_x                                                                               
    sty user_screen_origin_y

    lda screen_rows
    asl
    asl
    asl
    sta screen_height
    tax
    dex
    stx y_max

    ldx playfield_yc
    inx
    txa
    asl
    asl
    asl
    sta arena_y
    tax
    dex
    stx arena_y_above

    ldx screen_columns
    dex
    stx xc_max

    ldx screen_rows
    dex
    stx yc_max

    lda vaus_y
    sec
    sbc #2
    sta ball_vaus_y_upper
    tax
    dex
    stx ball_vaus_y_above

    lda vaus_y
    clc
    adc #8
    sta ball_vaus_y_lower

    lda vaus_y
    sec
    sbc #8
    sta ball_vaus_y_caught

    lda screen_columns
    sec
    sbc #1
    asl
    asl
    asl
    tax
    dex
    stx ball_max_x

    ldx playfield_yc
    inx
    txa
    asl
    asl
    asl
    sec
    sbc #2
    sta ball_min_y

    lda #26
    clc
    adc playfield_yc
    sta scry
    jsr scraddr
    lda scr
    clc
    adc #14
    sta screen_gate
    lda @(++ scr)
    clc
    adc #0
    sta @(++ screen_gate)

    lda screen_height
    sec
    sbc #ball_height
    sta ball_max_y

    rts
