clear_data:
    lda #$60
    sta $911e

    ;; Clean zero page (inluding VCPU area).
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
    0

    jmp set_format

preshift_common_sprites:
    0
    clrmw $00 $04 $d0 $05
    stmw <d >d $00 $04
    0

    lda dl
    sta preshifted_vaus
    lda dh
    sta @(++ preshifted_vaus)
    lda #<gfx_vaus
    sta sl
    lda #>gfx_vaus
    sta sh
    ldx #1
    ldy #10
    jsr preshift_huge_sprite

    lda dl
    sta preshifted_vaus_laser
    lda dh
    sta @(++ preshifted_vaus_laser)
    lda #<gfx_vaus_laser
    sta sl
    lda #>gfx_vaus_laser
    sta sh
    ldy #10
    jsr preshift_huge_sprite

    lda dl
    sta preshifted_vaus_extended
    lda dh
    sta @(++ preshifted_vaus_extended)
    lda #<gfx_vaus_extended
    sta sl
    lda #>gfx_vaus_extended
    sta sh
    ldy #11
    jsr preshift_huge_sprite

    lda dl
    sta preshifted_ball
    lda dh
    sta @(++ preshifted_ball)
    lda #<gfx_ball
    sta sl
    lda #>gfx_ball
    sta sh
    dex
    ldy #9
    jsr preshift_huge_sprite

    lda dl
    sta preshifted_ball_caught
    lda dh
    sta @(++ preshifted_ball_caught)
    lda #<gfx_ball_caught
    sta sl
    lda #>gfx_ball_caught
    sta sh
    ldy #9
    jsr preshift_huge_sprite

    lda dl
    sta @(+ laser_init sprite_init_pgl)
    lda dh
    sta @(+ laser_init sprite_init_pgh)
    lda #<gfx_laser
    sta sl
    lda #>gfx_laser
    sta sh
    ldy #9
    jsr preshift_huge_sprite

    lda dl
    sta gfx_obstacles
    lda dh
    sta @(++ gfx_obstacles)
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
    jsr clear_screen

    lda #0
    sta attraction_mode
    sta has_two_players
    sta active_player

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

    lda is_landscape
    bne +n
    ldx #20
    ldy #31
    jmp +m
n:  ldx #30
    ldy #27
m:  stx scrx2
    sty scry
    lda #<txt_credit
    ldy #>txt_credit
    jsr print_string_ay

if @*shadowvic?*
    $22 $02
end

loop:
    jsr test_fire
    beq start_one_player

    ; Switch to hiscore table.
    lda @(++ framecounter)
    cmp #5
    bne +l
    jsr hiscore_table
    bcs process_keypress
    jmp toplevel
l:

if @*has-digis?*
    jsr exm_work
end

    jsr poll_keypress
    bcc -loop

process_keypress:
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
    jmp -l

n:  cmp #keycode_l
    bne +n
    inc $9000
    inc user_screen_origin_x
    jmp -l

n:  cmp #keycode_k
    bne +n
    dec $9001
    dec user_screen_origin_y
    jmp -l

n:  cmp #keycode_j
    bne +n
    inc $9001
    inc user_screen_origin_y
    jmp -l

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

txt_arukanoido: @(string4x8 " ARUKANOIDO") 255
txt_copyright:  @(string4x8 " DEMO VERSION") 255
txt_rights:     @(string4x8 (+ "    REV. #" *revision*)) 255
txt_credit:     @(string4x8 " CREDIT  2") 255

__end_game:
