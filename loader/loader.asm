medium_pulse    = @(* 8 *pulse-medium*)
measuring_pulse = @(* 8 (+ *pulse-short* (/ (- *pulse-medium* *pulse-short*) 2)))

c2nwarp_start:
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
    sta $9124
    lda #>measuring_pulse
    sta $9125

    cli
    rts

; Expect short pulse.
tape_leader:
    jsr tape_get_bit
    bcc +l  ; Short pulse marking end of leader…
    dec tape_leader_countdown
    bpl +n
    inc tape_leader_countdown
n:  bpl intret ; (jmp)

    ;; Check if leader was long enough.
l:  lda tape_leader_countdown
    bne tape_restart_leader     ; Leader too short.
    lda #8
    sta tape_bit_counter
    lda #<tape_data
    sta $0314
    lda #>tape_data
    sta $0315

intret:
    lda $9121
    lda #$7f
    sta $912d
    jmp $eb18

tape_restart_leader:
    lda #@*tape-leader-length*
    sta tape_leader_countdown
    bne -intret

tape_data:
    jsr tape_get_bit
    ror tape_current_byte
    dec tape_bit_counter
    bne -intret

byte_complete:
    lda #8
    sta tape_bit_counter
    lda tape_current_byte   ; Save byte to its destination.
    ldy #0
    sta (tape_ptr),y
    inc tape_ptr            ; Advance destination address.
    bne +n
    inc @(++ tape_ptr)
n:  dec total_counter
    bne +n
    dec @(++ total_counter)
n:  dec tape_counter        ; All bytes loaded?
    bne -intret
    dec @(++ tape_counter)
    bne -intret

    sei
    lda #$7f                ; Turn off tape pulse interrupt.
    sta $912e
    sta $912d
    jmp (tape_callback)

tape_get_bit:
    lda $912d               ; Get timer underflow bit.
    ldx #>measuring_pulse
    stx $9125
    asl                     ; Move underflow bit into carry.
    asl
    rts
