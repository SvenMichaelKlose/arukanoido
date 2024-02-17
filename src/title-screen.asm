draw_title_screen:
    jsr blank_screen
    jsr clear_screen
    jsr clear_charset
    0
    stzb curchar 1
    call <print_scores_and_labels >print_scores_and_labels

    stzb curcol white
    stzb scrx 0
    stzb scry 8
    lday <gfx_arukanoido >gfx_arukanoido
    call <draw_bitmap >draw_bitmap

;    stmb <scrx2 >scrx2 9
;    stzb scry 8
;    lday <txt_arukanoido >txt_arukanoido
;    call <print_string_ay >print_string_ay

if @*demo?*
    stmb <scrx2 >scrx2 8
    stzb scry 23
    lday <txt_copyright >txt_copyright
    call <print_string_ay >print_string_ay
end

    stmb <scrx2 >scrx2 6
    stzb scry 25
    lday <txt_rights >txt_rights
    call <print_string_ay >print_string_ay
    0

    jsr draw_credits
    jmp init_screen

txt_arukanoido: @(string4x8 " ARUKANOIDO") 255
txt_copyright:  @(string4x8 " DEMO VERSION") 255
txt_rights:     @(string4x8 (+ "    REV. #" *revision*)) 255
txt_credit:     @(string4x8 " CREDIT  2") 255
