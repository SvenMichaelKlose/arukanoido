title_size      = @(length (fetch-file "obj/title.bin.exo"))
title_size_raw  = @(length (fetch-file "obj/title.bin"))
binary_size     = @(length (fetch-file "obj/arukanoido-tape.exo.prg"))
blk5_size       = @(length (fetch-file "obj/music-arcade-blk5.bin"))
total_size      = @(+ binary_size blk5_size)
cdec            = @(/ total_size 72)
number_0        = @(-- (+ #x8000 (* #x30 8)))

load_title:
    lda #0
    sta $9002
    sta is_loading_audio

    ; Load title screen.
    ldx #5
l:  lda title_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr c2nwarp_start
l:  jmp -l

get_mg_byte:
    sty exo_y2
    ldy #0
    lda (exo_s),y
    inc exo_s
    beq +n
    ldy exo_y2
    rts
n:  inc @(++ exo_s)
    ldy exo_y2
    rts

show_title:
    ; Stop tape motor.
    lda $911c
    ora #3
    sta $911c

    lda #<get_mg_byte
    sta get_byte
    lda #>get_mg_byte
    sta @(++ get_byte)
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

    ldx #5
l:  lda bin_cfg,x
    sta tape_ptr,x
    dex
    bpl -l
    jsr c2nwarp_start

    lda #<total_size
    sta total_counter
    lda #>total_size
    sta @(++ total_counter)

show_countdown:
    lda total_counter
    sta tmp
    lda @(++ total_counter)
    sta @(++ tmp)

    lda #0
    sta tmp2
l:  lda tmp
    sec
    sbc #<cdec
    sta tmp
    lda @(++ tmp)
    sbc #>cdec
    sta @(++ tmp)
    inc tmp2
    bcs -l

    lda #<number_0
    clc
    adc tmp2
    sta tmp
    lda #>number_0
    adc #0
    sta @(++ tmp)

    ldy #7
l:  lda (tmp),y
    sta mg_charset,y
    dey
    bpl -l

    bmi show_countdown ; (jmp)

load_blk5:
    ldx #5
l:  lda blk5_cfg,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr c2nwarp_start
    jmp show_countdown

start_game:
    lda #$00
    sta $9002

    ; Stop tape motor.
    lda $911c
    ora #3
    sta $911c

    ; Copy copying procedure to screen ($1000).
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
    ldx #@(++ (low binary_size))
    lda #@(++ (high binary_size))
    sta @(++ c)
    ldy #0
    bne +n ; (jmp)
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
    @(++ (low title_size)) @(++ (high title_size))
    <show_title >show_title

bin_cfg:
    <target >target
    @(++ (low binary_size)) @(++ (high binary_size))
    <load_blk5 >load_blk5

blk5_cfg:
    $00 $a0
    @(++ (low blk5_size)) @(++ (high blk5_size))
    <load_audio >load_audio

fill @(- 256 (mod *pc* 256))
target:
