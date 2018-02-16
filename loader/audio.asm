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
    jsr check_memory_expansion
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
    sta @(++ raw_size)

;    lda #$ff
;    sec
;    sbc bank_ptr
;    sta tmp
;    lda #$bf
;    sbc @(++ bank_ptr)
;    cmp @(++ raw_size)
;    bcs +n
;    lda tmp
;    cmp raw_size
;    bcc +n
;    inc bank
;    jmp next_digi
    
n:  jsr init_decruncher

    inc @(++ raw_size)
l:  jsr get_decrunched_byte
    sta $900e
    ldy #0
    inc $900f
    dec raw_size
    bne -l
    dec @(++ raw_size)
    bne -l
;    sta (bank_ptr),y
;    inc bank_ptr
;    bcc +n
;    inc @(++ bank_ptr)
;N:  dec raw_size
;    bne +n
;    dec @(++ raw_size)
;n:  bne -l
    dec digis_left
    jmp next_digi

check_memory_expansion:
    rts

init_memory_expansion:
    lda #ultimem_first_bank
    sta bank
    lda #$00
    sta bank_ptr
    lda #$a0
    sta @(++ bank_ptr)
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
