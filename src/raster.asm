cycles  = 16963
phase   = 21
delay   = 21
pos     = 4
line    = 99

if @nil
cycles  = 22150
phase   = 88
delay   = 23
pos     = 5
line    = 26
end

init_raster_ntsc:
    lda is_ntsc
    beq +r
    lda #<raster_ntsc
    sta $0314
    lda #>raster_ntsc
    sta $0315
    lda #<cycles
    sta $9124
    ldx #0
    ldy #line
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
l5: ldx #pos
l6: dex
    bne -l6
    nop
;IF NOT ntsc THEN [OPT pass:BIT $24:]
    lda #>cycles
    sta $9125
    cli
r:  rts

l7: ldx #delay
l8: dex
    bne -l8
;IF NOT ntsc THEN [OPT pass:NOP:]
    rts

raster_ntsc:
    cld
    lda #phase
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
rastercol:
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
    bit $24
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
n:  stx @(++ rastercol)

if @*has-digis?*
    lda currently_playing_digis
    bne +n      ; Digis are decrunched in game loop.
end
    jsr play_music
n:

    jmp $eabf
