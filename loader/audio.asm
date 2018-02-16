r:  sei
    lda #$7f
    sta $912e
    sta $912d

    ; Stop tape motor.
    lda $911c
    ora #3
    sta $911c
    jmp start_game

    ; Load and recompress audio depending on
    ; available memory expansion.
load_audio:
    lda #0
    sta $9002

    jsr check_memory_expansion
    bcc -r
    jsr init_memory_expansion

    lda #num_digis
    sta digis_left
    inc is_loading_audio

next_digi:
    lda digis_left
    beq -r

    lda #0
    sta audio_ptr
    sta tape_ptr
    lda #>tape_buffer
    sta @(++ tape_ptr)
    lda #<poll_loader_byte
    sta get_byte
    lda #>poll_loader_byte
    sta @(++ get_byte)
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

n:  jsr init_decruncher

    inc @(+ 2 raw_size)
l:  jsr get_decrunched_byte
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
n:  dec raw_size
    bne -l
    dec @(+ 1 raw_size)
    bne -l
    dec @(+ 2 raw_size)
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
