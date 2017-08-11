digitound_timer = @(/ 1108404 4329)

digisound_xlat_low:
digisound_xlat_high:

play_audio_sample:
    pha
    txa
    pha

    lda #>digitound_timer
    sta $9115

digisound_src:
    ldx $ffff
digisound_xlat_src:
    lda $ffff,x
    sta $900e

    inc @(++ digisound_src)
    bne +n
    inc @(+ 2 digisound_src)
n:

    dec digisound_counter
    bne +n
    dec @(++ digisound_counter)
    beq stop_digisound
n:

n:  pla
    tax
    pla
    rti

stop_digisound:
    lda #$7f
    sta $911e
    rts

start_digisound:
    stx digisound_src
    sty @(++ digisound_src)
    ldx #<digisound_xlat_low
    ldy #<digisound_xlat_low
    ora #0
    beq +n
    ldx #<digisound_xlat_high
    ldy #<digisound_xlat_high
n:  stx @(++ digisound_xlat_src)
    sty @(+ 2 digisound_xlat_src)

    lda #$40        ; Enable NMI timer and interrupt.
    sta $911b
    lda #$c0
    sta $911e

    lda #<digitound_timer
    sta $9114
    lda #>digitound_timer
    sta $9115

    ; Set NMI vector.
    lda #<play_audio_sample
    sta $318
    lda #>play_audio_sample
    sta $319

    cli
    rts
