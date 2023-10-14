clear_data:
    lda #$60
    sta $911e

    ;; Clean zero page (inluding VCPU area so that cannot be used yet.).
    lda #0
    tax
l:  cpx #@(-- uncleaned_zp)
    bcs +n
    sta 0,x
n:  dex
    bne -l

    0
    clrmw $00 $02 $13 $01
lowmem_ofs = @(- uncleaned_lowmem #x320)
    clrmw $20 $03 <lowmem_ofs >lowmem_ofs

if @(not *debug?*)
    clrmw <charset >charset $08 $00
end
if @*debug?*
    clrmw <charset >charset $00 $08
end

    movmw <loaded_sprite_inits >loaded_sprite_inits <sprite_inits >sprite_inits sprite_inits_size 0
    stmb <exm_needs_data >exm_needs_data $ff
    setmw <exm_buffers >exm_buffers $00 $02 light_cyan
    0

    jmp set_format

preshift_common_sprites:
    0
    clrmw $00 $04 $d0 $05
    stmw <d >d $00 $04

    mvmzw <preshifted_vaus >preshifted_vaus d
    stzw s <gfx_vaus >gfx_vaus
    ldxy 1 10
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_vaus_laser >preshifted_vaus_laser d
    stzw s <gfx_vaus_laser >gfx_vaus_laser
    ldyi 10
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_vaus_extended >preshifted_vaus_extended d
    stzw s <gfx_vaus_extended >gfx_vaus_extended
    ldyi 11
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_ball >preshifted_ball d
    stzw s <gfx_ball >gfx_ball
    ldxy 0 9
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <preshifted_ball_caught >preshifted_ball_caught d
    stzw s <gfx_ball_caught >gfx_ball_caught
    ldxy 0 9
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw @(low (+ laser_init sprite_init_pgl)) @(high (+ laser_init sprite_init_pgl)) d
    stzw s <gfx_laser >gfx_laser
    ldxy 0 9
    call <preshift_huge_sprite >preshift_huge_sprite

    mvmzw <gfx_obstacles >gfx_obstacles d
    0
    rts

start:
    lda #0
    sta is_playing_digis
    jsr init_hiscore
    jsr start_irq
    jsr init_score

toplevel:
    jsr clear_data
    jsr init_screen

    lda #0
    sta has_two_players
    sta active_player

restart_toplevel_views:
    jsr reset_framecounter
    lda #0
    sta current_toplevel_view
    jsr draw_title_screen

if @*shadowvic?*
    $22 $02
end

loop:
    jsr test_fire
    beq start_one_player

    ;; Rotate views.
    ; Switch every 786 frames.
    lda @(++ framecounter)
    cmp #3
    bne +get_toplevel_key
    inc current_toplevel_view
    ldx current_toplevel_view
    dex
    bne +n
    jsr draw_credits
    jsr reset_framecounter
    beq -loop ; (jmp)
n:  dex
    bne restart_toplevel_views
    jsr hiscore_table
    jsr reset_framecounter
    beq -loop ; (jmp)

if @*has-digis?*
    jsr exm_work
end

get_toplevel_key:
    jsr poll_keypress
    bcc -loop

    cmp #keycode_1
    bne +n
start_one_player:
    lda #0
    sta has_two_players
    lda #1
    sta active_player
    jmp +f
n:

    cmp #keycode_2
    bne +n
    lda #1
    sta has_two_players
    lda #1
    sta active_player
    jmp +f
n:

    cmp #keycode_t
    bne +n
    jsr hiscore_table
    jmp toplevel
n:

    cmp #keycode_t
    bne +n
    jsr hiscore_table
    jmp toplevel
n:

    cmp #keycode_h
    bne +n
    dec $9000
    dec user_screen_origin_x
    bne -loop ; (jmp)

n:  cmp #keycode_l
    bne +n
    inc $9000
    inc user_screen_origin_x
    bne -loop ; (jmp)

n:  cmp #keycode_k
    bne +n
    dec $9001
    dec user_screen_origin_y
    bne +l

n:  cmp #keycode_j
    bne +n
    inc $9001
    inc user_screen_origin_y
    bne +l

n:  cmp #keycode_f
    bne +n
    lda is_landscape
    eor #1
    sta is_landscape
    jsr set_format
    jmp toplevel

l:  jmp -loop

n:  cmp #keycode_b
    beq boot_basic

if @(not *has-digis?*)
    bne -l
end
if @*has-digis?*
    ldy has_digis
    beq -l
    cmp #keycode_m
    bne -l
    lda is_playing_digis
    eor #1
    sta is_playing_digis
    beq +n
    jsr audio_boost
n:  lda #snd_bonus_life
    jsr play_sound
    jmp -l
end

f:  jsr game
    jmp toplevel

draw_title_screen:
    jsr clear_screen
    0
    stzb curchar 1
    call <print_scores_and_labels >print_scores_and_labels

;    stzb scrx 5
;    stzb scry 20
;    lday <gfx_taito >gfx_taito
;    call <draw_bitmap >draw_bitmap

    stzb curcol white
    stmb <scrx2 >scrx2 9
    stzb scry 8
    call <clear_curchar >clear_curchar
    lday <txt_arukanoido >txt_arukanoido
    call <print_string_ay >print_string_ay

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

;    lda is_landscape
;    bne +n
;    ldx #20
;    ldy #31
;    jmp +m
;n:  ldx #30
;    ldy #27
;m:  stx scrx2
;    sty scry
;    lda #<txt_credit
;    ldy #>txt_credit
;    jmp print_string_ay
    rts

boot_basic:
    lda #0
    sta $9002
if @*rom?*
    sei
    lda #$7f
    sta $911d
    sta $911e
    cld
    ldx #$ff
    txs
    jsr $fd8d   ; Init memory.
    jsr $fd52   ; Init KERNAL.
    jsr $fdf9   ; Init VIAs.
    jsr $e518   ; Init VIC.
    jmp ($c000) ; Start BASIC.
end
if @(not *rom?*)
    jmp ($fffc)
end

draw_credits:
    jsr draw_round_intro_background

    lda playfield_yc
    clc
    adc #3
    sta scry

    0
    stzb curcol white
    stmb <scrx2 >scrx2 6
    lday <txt_press >txt_press
    call <print_string_ay >print_string_ay

    addzbi scry 4

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
    call <clear_curchar >clear_curchar

    stzb curcol yellow
    stmb <scrx2 >scrx2 4
    lday <txt_c3 >txt_c3
    call <print_string_ay >print_string_ay

    addzbi scry 2
    inczbi curchar
    call <clear_curchar >clear_curchar

    stzb curcol white
    stmb <scrx2 >scrx2 17
    lday <txt_c4 >txt_c4
    call <print_string_ay >print_string_ay
    0

    rts

txt_press:  @(string4x8 "PRESS FIRE, 1 OR 2") 255
txt_c1:     @(string4x8 "CODE & GRAPHICS:") 255
txt_c2:     @(string4x8 "SVEN MICHAEL KLOSE") 255
txt_c3:     @(string4x8 "CHIP SOUNDS:") 255
txt_c4:     @(string4x8 "ADRIAN FOX") 255

reset_framecounter:
    lda #0
    sta framecounter
    sta @(++ framecounter)
    rts

txt_arukanoido: @(string4x8 " ARUKANOIDO") 255
txt_copyright:  @(string4x8 " DEMO VERSION") 255
txt_rights:     @(string4x8 (+ "    REV. #" *revision*)) 255
;txt_credit:     @(string4x8 " CREDIT  2") 255

__end_game:
