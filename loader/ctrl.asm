title_size = @(length (fetch-file "obj/title.bin.exo"))
title_size_raw = @(length (fetch-file "obj/title.bin"))
binary_size = @(length (fetch-file *path-main*))

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
    jmp c2nwarp_start

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
