clear_data:
    lda #0
    tax
l:  cpx #@(-- hiscore)
    bcs +n
    sta 0,x
n:  sta $200,x
if @*debug?*
    sta charset,x
    sta @(+ 256 charset),x
    sta @(+ 512 charset),x
    sta @(+ 768 charset),x
    sta @(+ 1024 charset),x
    sta @(+ 1024 256 charset),x
    sta @(+ 1024 512 charset),x
    sta @(+ 1024 768 charset),x
end
    dex
    bne -l
    rts

start:
    ldx #$ff
    txs
    jsr clear_data

    ; Init VCPU.
    lda #<exec_script
    sta $316
    lda #>exec_script
    sta $317

    jsr init_hiscore
    jsr start_irq
    lda #0
    sta @(++ requested_song)
    lda #snd_bonus_life ; Tell that the tape has finished loading.
    jsr play_sound
    jsr wait_sound

toplevel:
    jsr init_game_mode
    jsr clear_screen
    jsr init_score
    jsr make_score_screen
    jsr display_score

    jsr wait_fire

l:  jsr game
    jmp -l
