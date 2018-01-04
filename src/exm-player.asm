exm_buffers = $1200

exm_extra_life_size = @(length (fetch-file "obj/round-intro.raw"))
exm_extra_life: @(fetch-file "obj/round-intro.exm")

exm_test:
    lda #<exm_extra_life
    ldy #>exm_extra_life
    jsr init_decruncher
    lda #<exm_extra_life_size
    ldy #>exm_extra_life_size

exm_start:
    ; Save number of samples.
    sta exm_play_rest
    iny
    sty @(++ exm_play_rest)

    ; Set pointers to double buffer.
    lda #0
    sta @(+ 1 exm_play_ptr)
    sta exm_play_dptr
    ldy #>exm_buffers
    sty @(+ 2 exm_play_ptr)
    sty @(++ exm_play_dptr)

    jsr audio_boost

    ; Decrunch first buffer.
    lda #1
    sta exm_needs_data
l:  jsr exm_work
    lda exm_needs_data
    bne -l
    lda #1
    sta exm_needs_data

    ldx #<digisound_timer_pal
    ldy #>digisound_timer_pal
    lda is_ntsc
    beq +n
    ldx #<digisound_timer_ntsc
    ldy #>digisound_timer_ntsc
n:  stx $9114
    sty $9115
    sty exm_timer

    ; Set NMI vector.
    lda #<exm_play_sample
    sta $318
    lda #>exm_play_sample
    sta $319

    lda #$40        ; Enable NMI timer and interrupt.
    sta $911b
    lda #$c0
    sta $911e

    rts

exm_work:
    lda exm_needs_data
    bmi +r
    beq +r

    ldx #88
    ldy #0
l:  jsr get_decrunched_byte
    sta (exm_play_dptr),y
    dec exm_play_rest
    bne +n
    dec @(++ exm_play_rest)
    beq +finished
n:  inc exm_play_dptr
    beq +buffer_filled
    dex
    bne -l

r:  rts

finished:
    dey
    sty exm_needs_data
    rts

buffer_filled:
    lda @(++ exm_play_dptr)
    eor #1
    sta @(++ exm_play_dptr)
    sty exm_needs_data
    rts
