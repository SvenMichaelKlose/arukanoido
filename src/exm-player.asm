exm_start:
    jsr digi_nmi_stop

    ; Set NMI vector.
    lda #<exm_play_sample
    sta $318
    lda #>exm_play_sample
    sta $319

    ; Set pointers to double buffer.
    lda #0
    sta @(+ 1 exm_play_ptr)
    sta exm_play_dptr
    ldy #>exm_buffers
    sty @(+ 2 exm_play_ptr)
    iny
    sty @(++ exm_play_dptr)

    ; Decrunch first buffer.
    lda #1
    sta exm_needs_data
    jsr exm_work

    jmp digi_nmi_start

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
    cmp #0
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
