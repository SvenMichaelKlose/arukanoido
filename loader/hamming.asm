;;; Deocde 7-bit word (4 bits data, 3 bits parity)
hamming_decode:
    ;; Make syndrome bits.
    ldy #0
    sty syndrome
    sta encoded
    lsr
    sta e1
    lsr
    sta e2
    lsr
    sta e3
    lsr
    sta e4
    lsr
    sta e5
    lsr
    sta e6

    eor e5
    eor e3
    eor e2
    lsr
    rol syndrome

    lda e6
    eor e4
    eor e3
    eor e1
    lsr
    rol syndrome

    lda e6
    eor e4
    eor e2
    eor encoded
    lsr
    rol syndrome

    bne error

    lda e3
    rts

error:
    ;; Correct error.
    ; Make bit mask.
    lda #7
    sec
    sbc syndrome
    tay
    lda #1
l:  cpy #0
    beq +n
    dey
    asl
    bne -l  ; (jmp)

    ;; Correct flipped bit.
n:  eor e3
    and #$0f
    rts
