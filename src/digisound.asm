digitound_timer = @(/ 1108404 4000)

digisound_xlat_low:
digisound_xlat_high:

play_audio_sample:
    sta digisound_a
    stx digisound_x

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

n:  dec digisound_counter
    bne +n
    dec @(++ digisound_counter)
;    beq stop_digisound

n:  ldx digisound_x
    lda digisound_a
    rti

stop_digisound:
    lda #$7f
    sta $911e
    rts

start_digisound:
    stx @(+ 1 digisound_src)
    sty @(+ 2 digisound_src)
    ldx #<digisound_xlat_low
    ldy #>digisound_xlat_low
    ora #0
    beq +n
    ldx #<digisound_xlat_high
    ldy #>digisound_xlat_high
n:  stx @(+ 1 digisound_xlat_src)
    sty @(+ 2 digisound_xlat_src)

    lda #<digitound_timer
    sta $9114
    lda #>digitound_timer
    sta $9115

    ; Set NMI vector.
    lda #<play_audio_sample
    sta $318
    lda #>play_audio_sample
    sta $319

    lda #$40        ; Enable NMI timer and interrupt.
    sta $911b
    lda #$c0
    sta $911e

    rts
