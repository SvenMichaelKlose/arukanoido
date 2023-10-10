if @*rom?*
    fill @(- #x8000 *pc*)
    org $a000
    <main >main
    <main >main
    "A0" $c3 $c2 $cd
end

if @*shadowvic?*
    org $1000
end

main:
    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

    ; Init VCPU.
    lda #<vcpu_exec
    sta $316
    lda #>vcpu_exec
    sta $317

    jsr blank_screen
    ; A is 0.
    sta currently_playing_digis
    sta current_song
    sta is_playing_digis

    ldx #$ff
    txs

if @(not *tape?*)
    lda #0
    sta has_ultimem
end

if @(& *tape?* *has-digis?* *ultimem?*)
    lda $1100
    sta has_ultimem
    beq +n
    ldx #@(-- num_tunes)
l:  lda $1101,x
    sta sample_addrs_l,x
    lda $1121,x
    sta sample_addrs_h,x
    lda $1141,x
    sta sample_addrs_b,x
    dex
    bpl -l
n:
end

if @*rom?*
    lda #<loaded_lowmem
    sta sl
    lda #>loaded_lowmem
    sta sh
    lda #<lowmem
    sta dl
    lda #>lowmem
    sta dh
    lda #<lowmem_size
    sta cl
    lda #>lowmem_size
    sta ch
    lda #0
    jsr moveram

    ; Copy sprite blitter to beginning of the stack.
    ldx #@(-- (- blitter_end blit_right))
l:  lda blitter_origin,x
    sta $100,x
    dex
    bpl -l
end

if @(not *shadowvic?*)
    ; Detect if PAL or NTSC VIC.
l:  lda $9004
    bne -l
l2: cmp $9004
    beq -l2
    bcs +n
    lda $9004
    jmp -l2
n:  ldx #0
    cmp #$90
    bcs +n
    inx
end
if @*shadowvic?*
    ldx #1
end
n:  stx is_ntsc
    stx is_landscape
    jsr set_format

if @*shadowvic?*
    jmp start
end
    jmp patch
