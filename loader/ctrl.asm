title_size = @(length (fetch-file "obj/title.bin.exo"))
title_size_raw = @(length (fetch-file "obj/title.bin"))
binary_size = @(length (fetch-file *path-main*))

load_title:
    lda #0
    sta $9002

    ; Load title screen.
    ldx #5
l:  lda title_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr c2nwarp_reset
    lda #<tape_leader1
    sta $314
    lda #>tape_leader1
    sta $315
    jsr c2nwarp_start
l:  jmp -l

show_title:
    lda #$00
    sta d
    sta mg_s
    lda #$40
    sta @(++ d)
    sta @(++ mg_s)
    lda #@(low title_size_raw)
    sta c
    lda #@(high title_size_raw)
    sta @(++ c)
    lda #<target
    ldy #>target
    jsr init_decruncher
    jsr decrunch_block_static
    jsr mg_display

    ; Load game.
    ldx #5
l:  lda cfg,x
    sta tape_ptr,x
    dex
    bpl -l
    ; Set IRQ vector.
    lda #<tape_leader2
    sta $314
    lda #>tape_leader2
    sta $315
    jsr c2nwarp_start

    ; Display countdown.
l:  lda tape_counter
    sta tmp
    ldx @(++ tape_counter)
    dex
    stx @(++ tmp)

    lda #0
    sta tmp2
l2: lda tmp
    sec
    sbc #<cdec
    sta tmp
    lda @(++ tmp)
    sbc #>cdec
    sta @(++ tmp)
    inc tmp2
    bcs -l2

    lda #<number_0
    clc
    adc tmp2
    sta tmp
    lda #>number_0
    adc #0
    sta @(++ tmp)

    ldy #7
l3: lda (tmp),y
    sta mg_charset,y
    dey
    bpl -l3

    jmp -l

start_game:
    lda #$00
    sta $9002

    ; Stop tape motor.
    lda $911c
    ora #3
    sta $911c

    ldx #@(- copy_forwards_end copy_forwards 1)
l:  lda copy_forwards,x
    sta $1000,x
    dex
    bpl -l
    jmp $1000

copy_forwards:
    lda #<target
    sta s
    lda #>target
    sta @(++ s)
    lda #$ff
    sta d
    lda #$11
    sta @(++ d)
    ldx #@(low binary_size)
    lda #@(++ (high binary_size))
    sta @(++ c)
    ldy #0
l:  lda (s),y
    sta (d),y
    iny
    bne +n
    inc @(++ s)
    inc @(++ d)
n:  dex
    bne -l
    dec @(++ c)
    bne -l
    jmp $120d
copy_forwards_end:

title_cfg:
    <target >target
    <title_size @(++ (high title_size))
    <show_title >show_title

cfg:
    <target >target
    <binary_size @(++ (high binary_size))
    <start_game >start_game

target:
