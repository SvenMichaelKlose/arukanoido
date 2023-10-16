medium_pulse    = @(* 8 *pulse-medium*)
long_pulse      = @(* 8 *pulse-long*)

reference_pulse: 0 0
last_handler: 0

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
    lda #<tape_leader1
    sta $0314
    lda #>tape_leader1
    sta $0315

    lda #$ff
    sta reference_pulse
    sta @(++ reference_pulse)
    sta $9124
    sta $9125
    cli
stop:
    rts

measuring_timer = @(- #xffff 55)
tape_leader1:
    lda #<measuring_timer
    sta $9124
    lda #>measuring_timer
    sta $9125
    lda #@*tape-leader-length*
    sta tape_leader_countdown
    ldx #<tape_leader2
    ldy #>tape_leader2
    bne +intretn ; (jmp)

; Measure reference pulse.
tape_leader2:
    jsr update_reference_pulse
    ldx #<tape_leader3
    ldy #>tape_leader3
    bne +intretn ; (jmp)

; Expect short pulse.
tape_leader3:
    jsr tape_get_bit
    bcs tape_restart_leader
    ldx #<tape_leader4
    ldy #>tape_leader4
    bne +intretn ; (jmp)

tape_restart_leader:
    inc $900f
    lda #<measuring_timer
    sta $9124
    lda #>measuring_timer
    sta $9125
    ldx #<tape_leader1
    ldy #>tape_leader1
    bne +intretn ; (jmp)

; Expect long pulse or short pulse to end leader.
tape_leader4:
    jsr tape_get_bit
    bcc +l  ; Short pulse marking end of leader…

    ;; Count down leader pulses.
    dec tape_leader_countdown
    ; Floor at 0.
    bpl +n
    inc tape_leader_countdown
n:  lda #<measuring_timer
    sta $9124
    lda #>measuring_timer
    sta $9125
    ldx #<tape_leader2
    ldy #>tape_leader2
    jmp intretn

l:  lda tape_leader_countdown
    bne tape_restart_leader     ; Leader too short.

tape_init_next_byte:
    lda #<measuring_timer
    sta $9124
    lda #>measuring_timer
    sta $9125
    lda #3
    sta last_handler
    ldx #<tape_data1
    ldy #>tape_data1

intretn:
    stx $0314
    sty $0315
intret:
    ;lda $9121
    lda #$7f
    sta $912d
    jmp $eb18

tape_data1:
    jsr update_reference_pulse
    lda #8
    sta tape_bit_counter
    ldx #<tape_data2
    ldy #>tape_data2
    bne intretn ; (jmp)

tape_data2:
    jsr tape_get_bit
    rol tape_current_byte
    dec tape_bit_counter
    bne intret

byte_complete:
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
    bne tape_init_next_byte
    dec @(++ tape_counter)
    bne tape_init_next_byte

    sei
    lda #$7f                ; Turn off tape pulse interrupt.
    sta $912e
    sta $912d
    jmp (tape_callback)

;;; Update reference pulse length.
update_reference_pulse:
    lda $9124           ; Read the timer's low byte which is your sample.
    ldx $9125
    ldy reference_pulse
    sty $9124
    ldy @(++ reference_pulse)
    sty $9125
    eor #$ff
    clc
    adc #55
    sta reference_pulse
    txa
    eor #$ff
    adc #$00
    sta @(++ reference_pulse)
    lsr @(++ reference_pulse)
    ror reference_pulse
    lda reference_pulse
    ldx @(++ reference_pulse)
    ldy last_handler
    rts

tape_get_bit:
    lda $912d               ; Get timer underflow bit.
    ldy $9124
    ldy $9125
    ldx reference_pulse
    stx $9124
    ldx @(++ reference_pulse)
    stx $9125
    asl     ; Move underflow bit into carry.
    asl
    rts
