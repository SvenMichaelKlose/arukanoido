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

    ; Blank screen.
    lda #0
    sta $9002
    sta is_playing_digis
    sta currently_playing_digis
    sta current_song

    ldx #$ff
    txs

if @(not *tape?*)
    lda #0
    sta has_ultimem
end

if @(& *tape?* *has-digis?*)
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
    sta s
    lda #>loaded_lowmem
    sta @(++ s)
    lda #<lowmem
    sta d
    lda #>lowmem
    sta @(++ d)
    lda #<lowmem_size
    sta c
    lda #>lowmem_size
    sta @(++ c)
    lda #0
    jsr moveram
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

    ; Init VCPU.
    lda #<exec_script
    sta $316
    lda #>exec_script
    sta $317

if @*shadowvic?*
    jmp start
end
    jmp patch
