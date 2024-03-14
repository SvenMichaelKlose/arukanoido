medium_pulse    = @(* 8 *pulse-medium*)
measuring_pulse = @(* 8 *pulse-timer*)

c2nwarp_start:
    ;; Disable interrups.
    sei
    lda #$7f
    sta $911e
    sta $912e
    sta $912d

    ;; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ;; Initialise VIA2 Timer 1 (cassette tape read).
    lda #%00000000  ; One-shot mode.
    sta $912b
    lda #%10000010  ; CA1 IRQ enable (tape pulse)
    sta $912e

    ;; Set handler.
    lda #<tape_leader
    sta $0314
    lda #>tape_leader
    sta $0315

    lda #@*tape-leader-length*
    sta tape_leader_countdown
    lda #<measuring_pulse
    sta $9126
    lda #>measuring_pulse
    sta $9125

    cli
    rts

; Read minimum number of long pulses before a short one.
tape_leader:
    lda $912d               ; Get timer underflow bit.
    ldx #>measuring_pulse
    stx $9125               ; Restart timer.
    asl                     ; Move underflow bit into carry.
    asl
    bcc +l  ; Short pulse marking end of leader…

    ;; Count down leader length.
    dec tape_leader_countdown
    ; Do not underflow.
    bpl +n
    inc tape_leader_countdown
n:  bpl done ; (jmp)

    ;; Check if leader was long enough.
l:  lda tape_leader_countdown
    bne tape_restart_leader     ; Too short…

    ;; Init bit read.
    lda #8
    sta tape_bit_counter
    lda #<tape_data
    sta $0314
    lda #>tape_data
    sta $0315

done:
    lda #$7f
    sta $912d
    pla
    tay
    pla
    tax
    pla
    rti

tape_restart_leader:
    lda #@*tape-leader-length*
    sta tape_leader_countdown
    bne -done

tape_data:
    lda $912d               ; Get timer underflow bit.
    ldx #>measuring_pulse
    stx $9125               ; Restart timer.
    asl                     ; Move underflow bit into carry.
    asl
    ror tape_current_byte
    dec tape_bit_counter
    bne -done

byte_complete:
    ;; Reset bit read.
    lda #8
    sta tape_bit_counter

    ;; Save byte to its destination.
    lda tape_current_byte
    ldy #0
    sta (tape_ptr),y

    ;; Advance destination address.
    inc tape_ptr
    bne +n
    inc @(++ tape_ptr)

    ;; Decrement total number of bytes for multi-block loads.
n:  dec total_counter
    bne +n
    dec @(++ total_counter)

    ;; Countdown current block.
n:  dec tape_counter
    bne -done
    dec @(++ tape_counter)
    bne -done

    ;; Turn interrupts back off.
    sei
    lda #$7f
    sta $912e
    sta $912d

    jmp (tape_callback)
