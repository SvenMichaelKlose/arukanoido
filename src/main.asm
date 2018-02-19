clear_data:
    lda #$60
    sta $911e

    lda #0
    tax
l:  cpx #@(-- uncleaned_zp)
    bcs +n
    sta 0,x
n:  dex
    bne -l

    0
    clrmw $00 $02 $00 $01
    clrmw $00 $03 $13 $00
    clrmw $20 $03 $e0 $00
    clrmw <charset >charset $00 $04
    movmw <loaded_sprite_inits >loaded_sprite_inits <sprite_inits >sprite_inits sprite_inits_size 0
    0

    lda #$ff
    sta exm_needs_data

    jmp set_format

start:
    jsr init_hiscore
    jsr start_irq
    lda #0
    sta @(++ requested_song)
    jsr init_score

toplevel:
    jsr clear_data
    jsr init_screen
    jsr clear_screen
    lda #1
    sta curchar
    jsr make_score_screen_title
    jsr display_score

    0
    stzb curcol red
    stzb scrx 5
    stzb scry 20
    lday <gfx_taito >gfx_taito
    call <draw_bitmap >draw_bitmap

    stzb curcol white
    stmb <scrx2 >scrx2 3
    stzb scry 23
    lday <txt_copyright >txt_copyright
    call <print_string_ay >print_string_ay

    stmb <scrx2 >scrx2 6
    stzb scry 25
    lday <txt_rights >txt_rights
    call <print_string_ay >print_string_ay
    0

    lda is_landscape
    bne +n
    ldx #21
    ldy #31
    jmp +m
n:  ldx #33
    ldy #27
m:  stx scrx2
    sty scry
    lda #<txt_credit
    ldy #>txt_credit
    jsr print_string_ay

l:  jsr test_fire
    beq +f

    jsr exm_work

    jsr poll_keypress
    bcc -l

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

n:  cmp #keycode_b
    beq boot_basic

    cmp #keycode_m
    bne -l
    lda is_playing_digis
    eor #1
    sta is_playing_digis
    beq +n
    jsr audio_boost
n:  lda #snd_miss
    jsr play_sound
    jmp -l

f:  lda #snd_miss
    jsr play_sound
    jsr wait_sound
    jsr round_intro
    jsr game
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

;txt_copyright:  @(string4x8 "[\\ 2017 TAYTO CORP JAPAN") 255
txt_copyright:  @(string4x8 "      DEMO VERSION") 255
txt_rights:     @(string4x8 (+ "   REVISION " *revision*)) 255
txt_credit:     @(string4x8 "CREDIT  0") 255
