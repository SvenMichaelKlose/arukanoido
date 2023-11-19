draw_credits_shared:
    jsr draw_round_intro_background
    jsr draw_credits

    lda playfield_yc
    clc
    adc #1
    sta scry

    0
    stzb curcol white
    stzb scrx2 6
    lday <txt_press >txt_press
    call <print_string_ay >print_string_ay
    addzbi scry 3
    0

    rts

draw_credits1:
    jsr draw_credits_shared

    0
    stzb curcol yellow
    stzb scrx2 4
    lday <txt_c1 >txt_c1
    call <print_string_ay >print_string_ay

    addzbi scry 2

    stzb curcol white
    stzb scrx2 9
    lday <txt_c2 >txt_c2
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol yellow
    stzb scrx2 4
    lday <txt_c3 >txt_c3
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol white
    stzb scrx2 17
    lday <txt_c4 >txt_c4
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol yellow
    stzb scrx2 4
    lday <txt_c5 >txt_c5
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol white
    stzb scrx2 12
    lday <txt_c6 >txt_c6
    call <print_string_ay >print_string_ay
    0

    jmp unblank_screen

draw_credits2:
    jsr draw_credits_shared

    0
    stzb curcol yellow
    stzb scrx2 4
    lday <txt_c7 >txt_c7
    call <print_string_ay >print_string_ay

    addzbi scry 2

    stzb curcol white
    stzb scrx2 16
    lday <txt_c8 >txt_c8
    call <print_string_ay >print_string_ay
    0

    jmp unblank_screen

txt_press:  @(string4x8 "PRESS FIRE, 1 OR 2") 255
txt_c1:     @(string4x8 "CODE & GRAPHICS:") 255
txt_c2:     @(string4x8 "SVEN MICHAEL KLOSE") 255
txt_c3:     @(string4x8 "CHIP SOUNDS:") 255
txt_c4:     @(string4x8 "ADRIAN FOX") 255
txt_c5:     @(string4x8 "DOH GFX & RASTER SYNC:") 255
txt_c6:     @(string4x8 "MICHAEL KIRCHER") 255
txt_c7:     @(string4x8 "COVER ART & LETTERING") 255
txt_c8:     @(string4x8 "BRYAN HENRY") 255
