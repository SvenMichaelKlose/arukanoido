if @nil

hamming_encode:
    sta data
    sta encoded
    lda data
    lsr
    sta d1
    lsr
    sta d2
    lsr
    sta d3

    lda d2
    eor d1
    eor data
    lsr
    rol encoded

    lda d3
    eor d1
    eor data
    lsr
    rol encoded
    
    lda d3
    eor d2
    eor data
    lsr
    rol encoded

    rts
end

hamming_decode:
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

    ;; Make syndrome bits.
    lda #0
    sta syndrome
    eor e4
    eor e2
    eor encoded
    lsr
    rol syndrome

    lda e6
    eor e4
    eor e3
    eor e1
    lsr
    rol syndrome

    lda e6
    eor e5
    eor e3
    eor e2
    lsr
    rol syndrome

    beq +no_error

    ;; Correct flipped bit.
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
n:  eor encoded
    sta encoded

no_error:
    lda encoded
    and #$0f;
    sta encoded
    rts
