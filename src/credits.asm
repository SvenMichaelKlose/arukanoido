draw_credits:
    jsr draw_round_intro_background

    lda playfield_yc
    clc
    adc #1
    sta scry

    0
    stzb curcol white
    stmb <scrx2 >scrx2 6
    lday <txt_press >txt_press
    call <print_string_ay >print_string_ay

    addzbi scry 3

    stzb curcol yellow
    stmb <scrx2 >scrx2 4
    lday <txt_c1 >txt_c1
    call <print_string_ay >print_string_ay

    addzbi scry 2

    stzb curcol white
    stmb <scrx2 >scrx2 9
    lday <txt_c2 >txt_c2
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol yellow
    stmb <scrx2 >scrx2 4
    lday <txt_c3 >txt_c3
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol white
    stmb <scrx2 >scrx2 17
    lday <txt_c4 >txt_c4
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol yellow
    stmb <scrx2 >scrx2 4
    lday <txt_c5 >txt_c5
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar

    stzb curcol white
    stmb <scrx2 >scrx2 12
    lday <txt_c6 >txt_c6
    call <print_string_ay >print_string_ay
    0

    rts

txt_press:  @(string4x8 "PRESS FIRE, 1 OR 2") 255
txt_c1:     @(string4x8 "CODE & GRAPHICS:") 255
txt_c2:     @(string4x8 "SVEN MICHAEL KLOSE") 255
txt_c3:     @(string4x8 "CHIP SOUNDS:") 255
txt_c4:     @(string4x8 "ADRIAN FOX") 255
txt_c5:     @(string4x8 "DOH GRAPHICS:") 255
txt_c6:     @(string4x8 "MICHAEL KIRCHER") 255
