r:  rts

    ; Load and recompress audio depending on
    ; available memory expansion.
load_digis:
    lda #num_digis
    sta digis_left
    ldy #0
    sty audio_ptr
    inc is_loading_audio

    jsr check_memory_expansion
    jsr init_memory_expansion

next_digi:
    lda digis_left
    beq -r

    jsr poll_loader_byte
    sta raw_size
    jsr poll_loader_byte
    sta @(++ raw_size)
    jsr poll_loader_byte

    lda #$ff
    sec
    sbc bank_ptr
    sta tmp
    lda #$bf
    sbc @(++ bank_ptr)
    cmp @(++ raw_size)
    bcc +n
    lda tmp
    cmp raw_size
    bcc +n
    inc bank
    jmp next_digi
    
n:  jsr init_decruncher
    inc @(++ raw_size)

l:  jsr get_decrunched_byte
    ldy #0
    sta (bank_ptr),y
    inc bank_ptr
    bcc +n
    inc @(++ bank_ptr)
N:  dec raw_size
    bne +n
    dec @(++ raw_size)
n:  bne -l
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
    ldy audio_ptr
    cpy tape_ptr
    beq poll_loader_byte
    lda tape_buffer,y
    rts
