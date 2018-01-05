exm_start:
    ldx #$60        ; Disable NMI timer and interrupt.
    stx $911e

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

    ; Decrunch first buffer.
    lda #1
    sta exm_needs_data
    jsr exm_work

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

    lda #$40        ; Set periodic timer.
    sta $911b
    lda #$e0        ; Enable NMI timer and interrupt.
    sta $911e

    rts

exm_work:
    pha
    lda exm_needs_data
    bmi +r
    beq +r

    txa
    pha
    tya
    pha

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

r2: pla
    tay
    pla
    tax
r:  pla
    rts

finished:
    dex
    beq +n
    lda #$b0
l:  sta (exm_play_dptr),y
    inc exm_play_dptr
    dex
    bne -l

n:  dey
    sty exm_needs_data

    jmp -r2

buffer_filled:
    lda @(++ exm_play_dptr)
    eor #1
    sta @(++ exm_play_dptr)
    sty exm_needs_data
    jmp -r2
