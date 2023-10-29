cycles_ntsc  = 16963
phase_ntsc   = 21
delay_ntsc   = 21
pos_ntsc     = 4
line_ntsc    = 99

cycles_pal  = 22150
phase_pal   = 88
delay_pal   = 23
pos_pal     = 0
line_pal    = 102

init_raster:
    lda is_ntsc
    bne init_raster_ntsc
    jmp init_raster_pal

init_raster_ntsc:
    lda #<raster_ntsc
    sta $0314
    lda #>raster_ntsc
    sta $0315
    lda #<cycles_ntsc
    sta $9124
    ldx #0
    ldy #line_ntsc
l1: cpy $9004
    bne -l1
    iny
    iny
l2: cpy $9004
    bne -l2
    jsr +l7
    iny
    cpy $9004
    beq +l3
    nop
    nop
l3: jsr +l7
    nop
    iny
    cpy $9004
    beq +l4
    bit $24
l4: jsr +l7
    nop
    iny
    cpy $9004
    bne +l5
l5: ldx #pos_ntsc
l6: dex
    bne -l6
    nop
    lda #>cycles_ntsc
    sta $9125
    cli
r:  rts

l7: ldx #delay_ntsc
l8: dex
    bne -l8
    rts

raster_ntsc:
    cld
    lda #phase_ntsc
    sec
    sbc $9124
    cmp #10
    bcc +l0
    jmp $eabf
l0: sta @(++ raster_ntsc_mod)
raster_ntsc_mod:
    bcc raster_ntsc_mod
    lda #$a9
    lda #$a9
    lda #$a9
    lda #$a9
    lda #$a5
    nop

    nop
    ldx #35
rastercol_ntsc:
l2: lda #0
    ldy #@(+ reverse red)
    sta $900f
    sty $900f
    bit $24
    bit $24

    sta $900f
    sty $900f
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    nop
    sta $f000,x
    nop
    dex
    bne -l2

    inc framecounter
    beq +n
    inc @(++ framecounter)
n:

    ldx #@(+ reverse yellow)
    lda framecounter
    lsr
    lsr
    bcs +n
    ldx #@(+ reverse red)
n:  stx @(++ rastercol_ntsc)

if @*has-digis?*
    lda currently_playing_digis
    bne +n      ; Digis are decrunched in game loop.
end
    jsr play_music
n:

    jsr blink_score_label
    jmp $eabf


init_raster_pal:
    lda #4
    sta pal_raster_correction
    lda #<raster_pal
    sta $0314
    lda #>raster_pal
    sta $0315
    lda #<cycles_pal
    sta $9124
    ldx #0
    ldy #line_pal
l1: cpy $9004
    bne -l1
    iny
    iny
l2: cpy $9004
    bne -l2
    jsr +l7
    iny
    cpy $9004
    beq +l3
    nop
    nop
l3: jsr +l7
    nop
    iny
    cpy $9004
    beq +l4
    bit $24
l4: jsr +l7
    nop
    iny
    cpy $9004
    bne +l5
l5: ldx #pos_pal
l6: dex
    bne -l6
    nop
    bit $24
    lda #>cycles_pal
    sta $9125
    cli
r:  rts

l7: ldx #delay_pal
l8: dex
    bne -l8
    nop
    rts

raster_pal:
    cld
    lda #phase_pal
    sec
    sbc $9124
    cmp #10
    bcc +l0
    jmp $eabf
l0: sta @(++ raster_pal_mod)
raster_pal_mod:
    bcc raster_pal_mod
    lda #$a9
    lda #$a9
    lda #$a9
    lda #$a9
    lda #$a5
    nop

    nop
    ldx #35
rastercol_pal:
l2: lda #0
    ldy #@(+ reverse red)
    sta $900f
    sty $900f
    sta $f000

    sta $900f
    sty $900f
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    bit $24
    sta $f000
    sta $f000
    sta $f000,x
    nop
    dex
    bne -l2

    inc framecounter
    beq +n
    inc @(++ framecounter)
n:

    ldx #@(+ reverse yellow)
    lda framecounter
    lsr
    lsr
    bcs +n
    ldx #@(+ reverse red)
n:  stx @(++ rastercol_pal)

if @*has-digis?*
    lda currently_playing_digis
    bne +n      ; Digis are decrunched in game loop.
end
    jsr play_music
    dec pal_raster_correction
    bpl +n
    jsr play_music
    lda #4
    sta pal_raster_correction
n:

    jsr blink_score_label
    jmp $eabf
