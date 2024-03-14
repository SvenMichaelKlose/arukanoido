medium_pulse    = @(* 8 *pulse-medium*)
measuring_pulse = @(* 8 *pulse-timer*)

main:
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
l:  bne -l

; Read minimum number of long pulses before a short one.
tape_leader:
    jsr getbit
    bcc +l  ; Short pulse marking end of leader…

    ;; Count down leader length.
    dec tape_leader_countdown
    bpl +done
    ; Do not underflow.
    inc tape_leader_countdown
    bpl done ; (jmp)

    ;; Start data read.
    ; Check if leader was long enough.
l:  lda tape_leader_countdown
    bne tape_restart_leader     ; Leader too short.
    ; Init bit read.
    lda #<tape_data
    sta $0314
nextbyte:
    lda #8
    sta tape_bit_counter

done:
    lda #$7f
    sta $912d
    jmp $eb18

tape_restart_leader:
    lda #@*tape-leader-length*
    sta tape_leader_countdown
    bne -done

tape_data:
    jsr getbit
    ror tape_current_byte
    dec tape_bit_counter
    bne -done

byte_complete:
    ; Save byte to its destination.
    lda tape_current_byte
    ldy #0
    sta (tape_ptr),y

    ; Advance destination address.
    inc tape_ptr
    bne +n
    inc @(++ tape_ptr)

    ; Countdown .
n:  dec tape_counter
    bne -nextbyte
    dec @(++ tape_counter)
    bne -nextbyte

    jmp $2000

getbit:
    lda $912d               ; Get timer underflow bit.
    ldx #>measuring_pulse
    stx $9125               ; Restart timer.
    asl                     ; Move underflow bit into carry.
    asl
    rts
