tape_buffer = $7400

r:  sei
    lda #$7f
    sta $912e
    sta $912d

    ; Stop tape motor.
    lda $911c
    ora #3
    sta $911c

    ; Copy sample addresses to screen,
    ldx #0
l:  lda $7300,x
    sta $1101,x
    dex
    bne -l

    jmp start_game

    ; Load and recompress audio depending on
    ; available memory expansion.
load_audio:
    lda #0
    sta $9002   ; Blank screen.
    sta $1100   ; Tell loaded game that there's no Ultimem (yet).

    jsr check_memory_expansion
    bcc -r
bcs -r

    ; Tell loaded game that we have an Ultimem expansion.
    lda #1
    sta $1100

    jsr init_memory_expansion

    lda #num_digis
    sta digis_left
    inc is_loading_audio

    lda #<poll_loader_byte
    sta get_byte
    lda #>poll_loader_byte
    sta @(++ get_byte)

next_digi:
    lda digis_left
    beq -r

    lda #0
    sta audio_ptr
    lda #<tape_buffer
    sta tape_ptr
    lda #>tape_buffer
    sta @(++ tape_ptr)
    lda #<tape_leader2
    sta $314
    lda #>tape_leader2
    sta $315
    jsr c2nwarp_start

    jsr poll_loader_byte
    sta raw_size
    jsr poll_loader_byte
    sta @(+ 1 raw_size)
    jsr poll_loader_byte
    sta @(+ 2 raw_size)

    lda #num_digis
    sec
    sbc digis_left
    tax
    lda sample_order,x
    tax
    lda bank_ptr
    sta @(-- samples_l),x
    lda @(++ bank_ptr)
    sta @(-- samples_h),x
    lda bank
    sta @(-- samples_b),x
    jsr set_bank

    jsr init_decruncher

l:  jsr get_decrunched_byte
    tax
    sta $900e
    inc $900f
    ldy #0
    sta (bank_ptr),y
    inc bank_ptr
    bne +n
    inc @(++ bank_ptr)
    lda @(++ bank_ptr)
    cmp #$c0
    bne +n
    lda #$a0
    sta @(++ bank_ptr)
    inc bank
    jsr set_bank
n:  txa
    bne -l
    dec digis_left
    jmp next_digi

check_memory_expansion:
    lda $9f55       ; Unhide registers.
    lda $9faa
    lda $9f01
    lda $9ff3
    cmp #$11
    beq +f
    cmp #$12
    beq +f
    clc
    rts

f:  sec
    rts

init_memory_expansion:
    lda #ultimem_first_bank
    sta bank
    lda #0
    sta bank_ptr
    sta $9fff
    lda #$a0
    sta @(++ bank_ptr)

set_bank:
    lda bank
    sta $9ffe
    rts

poll_loader_byte:
    php
    sty exo_y2
l:  ldy audio_ptr
    cpy tape_ptr
    beq -l
    lda tape_buffer,y
    inc audio_ptr
    ldy exo_y2
    plp
    rts

sample_order:
    snd_round_break
    snd_hit_obstacle
    snd_growing_vaus
    snd_bonus_life
    snd_game_over
    snd_laser
    snd_miss
    snd_hit_doh
    snd_reflection_silver
    snd_reflection_high
    snd_reflection_low
    snd_theme
    snd_round
    snd_doh_dissolving
    snd_doh_round
    snd_hiscore
