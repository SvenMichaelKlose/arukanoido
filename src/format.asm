portrait_color_1up  = @(+ colors 2)
portrait_color_2up  = @(+ colors 11)

format_portrait:
    15          ; screen_columns
    32          ; screen_rows
    @(* 29 8)   ; vaus_y
    2           ; playfield_yc
    4           ; txt_1up_x
    0           ; txt_1up_y
    1           ; score1_x
    1           ; score1_y
    10          ; txt_hiscore1_x
    0           ; txt_hiscore1_y
    12          ; hiscore1_x
    1           ; hiscore1_y
    23          ; txt_2up_x
    0           ; txt_2up_y
    20          ; score2_x
    1           ; score2_y
    <portrait_color_1up
    >portrait_color_1up
    <portrait_color_2up
    >portrait_color_2up

landscape_color_1up = @(+ colors 18)
landscape_color_2up = @(+ colors 120 18)

format_landscape:
    20          ; screen_columns
    28          ; screen_rows
    @(* 27 8)   ; vaus_y
    0           ; playfield_yc
    36          ; txt_1up_x
    0           ; txt_1up_y
    33          ; score1_x
    1           ; score1_y
    30          ; txt_hiscore1_x
    3           ; txt_hiscore1_y
    33          ; hiscore1_x
    4           ; hiscore1_y
    36          ; txt_2up_x
    6           ; txt_2up_y
    33          ; score2_x
    7           ; score2_y
    <landscape_color_1up
    >landscape_color_1up
    <landscape_color_2up
    >landscape_color_2up

set_format:
    lda is_landscape
    bne set_format_landscape

set_format_portrait:
    0
    movmw <format_portrait >format_portrait <screen_columns >screen_columns 20 0
    0
    jmp set_format_common

set_format_landscape:
    0
    movmw <format_landscape >format_landscape <screen_columns >screen_columns 20 0
    0

set_format_common:
    lda screen_columns
    asl
    sta double_screen_columns

    ; Make line addresses.
    lda #<screen
    sta sl
    lda #>screen
    sta sh
    ldx #0
l:  lda sl
    sta line_addresses_l,x
    lda sh
    sta line_addresses_h,x
    lda sl
    clc
    adc screen_columns
    sta sl
    bcc +n
    inc sh
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
    sbc #2      ; Rounded half ball_height.
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

    lda is_landscape
    bne set_format_landscape2

set_format_portrait2:
    lda screen_height
    sec
    sbc #ball_height
    sta ball_max_y
    rts

set_format_landscape2:
    ldx screen_height
    dex
    stx ball_max_y
    rts
