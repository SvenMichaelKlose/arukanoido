digisound_rate = 4000
digisound_timer_pal = @(/ (cpu-cycles :pal) digisound_rate)
digisound_timer_ntsc = @(/ (cpu-cycles :ntsc) digisound_rate)

digisound_xlat_low:
digisound_xlat_high:

play_audio_sample:
    sta digisound_a
    stx digisound_x

    lda #>digisound_timer_pal
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
    rti

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

    ldx #<digisound_timer_pal
    ldy #>digisound_timer_pal
    lda is_ntsc
    bne +n
    ldx #<digisound_timer_ntsc
    ldy #>digisound_timer_ntsc
n:  stx $9114
    sty $9115

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
