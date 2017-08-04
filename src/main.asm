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

    jsr init_score

toplevel:
    jsr init_game_mode
    lda #8
    sta $900f
    jsr clear_screen
    jsr make_score_screen
    jsr display_score

    lda #1
    sta curchar
    lda #<txt_credits
    sta s
    lda #>txt_credits
    sta @(++ s)
    lda #20
    sta scrx2
    lda #31
    sta scry
    jsr print_string

    jsr wait_fire

l:  jsr game
    jmp -l

txt_credits:
    @(string4x8 "CREDITS  0") 255
