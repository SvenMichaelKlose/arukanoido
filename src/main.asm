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

    movmw <loaded_sprite_inits >loaded_sprite_inits <sprite_inits >sprite_inits sprite_inits_size 0
if @*has-digis?*
    stmb <exm_needs_data >exm_needs_data $ff
    setmw <exm_buffers >exm_buffers $00 $02 light_cyan
end
    0

    jsr clear_charset
    jmp set_format

start:
    lda #0
    sta is_playing_digis
    jsr init_hiscore
    jsr init_music
    jsr init_irq
    jsr init_score

toplevel:
    jsr clear_data
    jsr init_screen

    lda #0
    sta has_two_players
    sta active_player

restart_toplevel_views:
    lda #0
    sta current_toplevel_view
    jsr draw_title_screen

if @*shadowvic?*
    $22 $02
end

loop_with_framecounter_reset:
    jsr reset_framecounter
loop:
    jsr test_fire
    beq start_one_player

    ;; Rotate views.
view_title      = 0
view_credits    = 1
view_hiscore    = 2
    ; Not for +16K.
    lda has_24k
    beq +get_toplevel_key
    ; Switch every 786 frames.
    lda @(++ framecounter)
    cmp #3
    bne +get_toplevel_key
    inc current_toplevel_view
    ldx current_toplevel_view
    dex
    bne +n
    jsr draw_credits
    jmp loop_with_framecounter_reset
n:  dex
    bne restart_toplevel_views
    jsr hiscore_table
    jmp loop_with_framecounter_reset

if @*has-digis?*
    jsr exm_work
end

get_toplevel_key:
    jsr poll_key
    bcc -loop
    jsr wait_key_release

    cmp #keycode_1
    bne +n
start_one_player:
    ldx #0
    stx has_two_players
    inx
    stx active_player
    jmp +f
n:

    ; No two player mode for 16K.
    ldy has_24k
    beq +n
    cmp #keycode_2
    bne +n
    lda #1
    sta has_two_players
    sta active_player
    jmp +f
n:

    cmp #keycode_t
    bne +n
    jsr hiscore_table
    lda #view_hiscore
    sta current_toplevel_view
    jmp loop_with_framecounter_reset
n:

    ;; Move screen left.
    cmp #keycode_h
    bne +n
    dec $9000
    dec user_screen_origin_x
    bne -loop ; (jmp)

    ;; Move screen right.
n:  cmp #keycode_l
    bne +n
    inc $9000
    inc user_screen_origin_x
    bne +l ; (jmp)

    ;; Move screen up.
n:  cmp #keycode_k
    bne +n
    dec $9001
    dec user_screen_origin_y
    bne +l

    ;; Move screen down.
n:  cmp #keycode_j
    bne +n
    inc $9001
    inc user_screen_origin_y
    bne +l

    ;; Toggle portrait/landscape format.
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
    lda #snd_round_break
    jsr play_sound
    jmp -l
end

f:  jsr game
    jmp toplevel

draw_title_screen:
    jsr clear_screen
    jsr clear_charset
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
