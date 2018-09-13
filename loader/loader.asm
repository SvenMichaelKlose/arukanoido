tape_leader_length = 32

timer = @(* 8 *pulse-long*)

c2nwarp_reset:
    lda #0
    ldy #15
l:  sta pulses,y
    dey
    bpl -l
    rts

c2nwarp_start:
    lda #tape_leader_length
    sta tape_leader_countdown

    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ; Initialise VIA2 Timer 1 (cassette tape read).
    ldx #@(low *tape-pulse*) ; Restart timer.
    sta $9124
    ldx #@(high *tape-pulse*) ; Restart timer.
    sta $9125
    lda #%00000000  ; One-shot mode.
    sta $912b
    lda #%10000010  ; CA1 IRQ enable (tape pulse)
    sta $912e

    cli
    rts

tape_get_bit:
    lda $912d               ; Get timer underflow bit.
    ldx #@(high *tape-pulse*) ; Restart timer.
    stx $9125
    ldx $9121
    asl     ; Move underflow bit into carry.
    asl
    rts

tape_leader1:
    jsr tape_get_bit
    bcc +n
    lda tape_leader_countdown
    bmi +j
    lda #tape_leader_length
    sta tape_leader_countdown
    jmp intret
j:  ldx #<tape_leader1end
    ldy #>tape_leader1end
    jmp intretn
n:  dec tape_leader_countdown
    jmp intret

tape_leader1end:
    lda #<timer
    sta $9124
    lda #>timer
    sta $9125
    lda #0
    sta tape_bit_counter
    lda #0
    sta tape_leader_countdown
    ldx #<tape_sync
    ldy #>tape_sync
    jmp intretn

tape_sync:
    jsr get_pulse_length
    lda tape_bit_counter
    eor tape_leader_countdown
    and #3
    asl
    asl
    tay

    ; Lower bound
    lda pulses,y
    ora @(++ pulses),y
    beq +m
    lda @(++ s)
    cmp @(++ pulses),y
    beq +k
    bcs +l
    bcc +m
k:  lda s
    cmp pulses,y
    bcs +l
m:  lda s
    sta pulses,y
    lda @(++ s)
    sta @(++ pulses),y

    ; Upper bound
l:  lda @(+ 2 pulses),y
    ora @(+ 3 pulses),y
    beq +m
    lda @(++ s)
    cmp @(+ 3 pulses),y
    beq +k
    bcs +m
    bcc +l
k:  lda s
    cmp @(+ 2 pulses),y
    beq +l
    bcc +l
m:  lda s
    sta @(+ 2 pulses),y
    lda @(++ s)
    sta @(+ 3 pulses),y

    ; Determine next pulse length.
l:  lda tape_bit_counter
    clc
    adc #1
    and #3
    sta tape_bit_counter
    bne intret
n:  dec tape_leader_countdown
    beq fill_map
    bne intret

fill_map:
    ldx #4
    ldy #10
l:  lda @(+ 0 pulses),y
    clc
    adc @(+ 2 pulses),y
    sta tmp
    lda @(+ 1 pulses),y
    adc @(+ 3 pulses),y
    lsr
    sta @(++ pulsesm),x
    lda tmp
    ror
    sta pulsesm,x
    dex
    dex
    dey
    dey
    dey
    dey
    bpl -l

    lda #tape_leader_length
    sta tape_leader_countdown
    ldx #@(low *tape-pulse*)
    sta $9124
    ldx #@(high *tape-pulse*)
    sta $9125
    ldx #<tape_leader2
    ldy #>tape_leader2

intretn:
    stx $314
    sty $315
intret:
    lda #$7f
    sta $912d
    jmp $eb18

tape_leader2:
    jsr tape_get_bit
    bcc +n
    lda tape_leader_countdown
    bmi +j
    lda #tape_leader_length
    sta tape_leader_countdown
    jmp intret
j:  ldx #<tape_leader2end
    ldy #>tape_leader2end
    jmp intretn
n:  dec tape_leader_countdown
    jmp intret

tape_leader2end:
    lda #<timer
    sta $9124
    lda #>timer
    sta $9125
    lda #4
    sta tape_bit_counter
    ldx #<tape_loader_data
    ldy #>tape_loader_data
    jmp intretn

tape_loader_data:
    jsr get_pulse_length

    ldx #4
l:  lda @(++ s)
    cmp @(++ pulsesm),x
    beq +k
    bcs +m
    bcc +n

k:  lda s
    cmp pulsesm,x
    bcs +m

n:  dex
    dex
    bpl -l
    lda #0
    beq +n

m:  txa
    lsr
    clc
    adc #1

n:  asl tape_current_byte
    asl tape_current_byte
    ora tape_current_byte
    sta tape_current_byte
    dec tape_bit_counter
    beq byte_complete
r:  jmp intret

n:  inc tape_ptr
    jmp intret

byte_complete:
    lda #4                  ; Reset bit count.
    sta tape_bit_counter
    lda tape_current_byte   ; Save byte to its destination.
    sta (tape_ptr),y
    lda is_loading_audio
    bne -n
    inc tape_ptr            ; Advance destination address.
    bne +n
    inc @(++ tape_ptr)
n:  dec total_counter
    bne +n
    dec @(++ total_counter)
n:  dec tape_counter        ; All bytes loaded?
    bne -r                  ; No...
    dec @(++ tape_counter)
    bne -r                  ; No...

    sei
    lda #$7f                ; Turn off tape pulse interrupt.
    sta $912e
    sta $912d

    jmp (tape_callback)

get_pulse_length:
    lda $9124       ; Read the timer's low byte which is your sample.
    ldx $9125
    ldy #<timer
    sty $9124
    ldy #>timer
    sty $9125       ; Write high byte to restart the timer.
    ldy #0
    cmp #4
    bcs +n
    inx
n:
    sta s               ; Make timer value index into map.
    stx @(++ s)
    rts

inc_s:
    inc s
    bne +n
    inc @(+ 1 s)
n:  rts

inc_d:
    inc d
    bne +n
    inc @(+ 1 d)
n:  rts

inc_c:
    inc c
    bne +n
    inc @(+ 1 c)
n:  rts

dec_d:
    pha
    dec d
    lda d
    cmp #$ff
    bne +n
    dec @(+ 1 d)
n:  pla
    rts

dec_c:
    dec c
    lda c
    cmp #$ff
    bne +n
    dec @(+ 1 c)
n:  lda c
    ora @(+ 1 c)
    rts
