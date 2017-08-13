clear_data:
    lda #0
    tax
l:  cpx #@(-- hiscore)
    bcs +n
    sta 0,x
n:  cpx #$e0
    bcs +n
    sta $320,x
n:  cpx #$13
    bcs +n
    sta $300,x
n:  sta $200,x
    sta charset,x
    sta @(+ 256 charset),x
    sta @(+ 512 charset),x
    sta @(+ 768 charset),x
    sta @(+ 1024 charset),x
    sta @(+ 1024 256 charset),x
    sta @(+ 1024 512 charset),x
    sta @(+ 1024 768 charset),x
    dex
    bne -l
    rts

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

    lda #red
    sta curcol
    lda #5
    sta scrx
    lda #20
    sta scry
    lda #<gfx_taito
    ldy #>gfx_taito
    jsr draw_bitmap

    lda #white
    sta curcol
    lda #3
    sta scrx2
    lda #23
    sta scry
    lda #<txt_copyright
    ldy #>txt_copyright
    jsr print_string_ay

    lda #6
    sta scrx2
    lda #25
    sta scry
    lda #<txt_rights
    ldy #>txt_rights
    jsr print_string_ay

    lda #21
    sta scrx2
    lda #31
    sta scry
    lda #<txt_credit
    ldy #>txt_credit
    jsr print_string_ay

l:  jsr test_fire
    beq +f

    jsr poll_keypress
    bcc -l

    cmp #keycode_h
    bne +n
    dec $9000
    jmp -l
n:
    cmp #keycode_l
    bne +n
    inc $9000
    jmp -l
n:
    cmp #keycode_k
    bne +n
    dec $9001
    jmp -l
n:
    cmp #keycode_j
    bne -l
    inc $9001
    jmp -l

f:  lda #snd_coin
    jsr play_sound
    jsr wait_sound
    jsr round_intro
    jsr game
    jmp toplevel

txt_copyright:  @(string4x8 "[\\ 2017 TAYTO CORP JAPAN") 255
txt_rights:     @(string4x8 "ALL RIGHTS RESERVED") 255
txt_credit:     @(string4x8 "CREDIT  0") 255
