if @*rom?*
    fill @(- #x8000 *pc*)
    org $a000
    <main >main
    <main >main
    "A0" $c3 $c2 $cd
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

    ldx #$ff
    txs

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
n:  stx is_ntsc
    stx is_landscape
    jsr set_format

    ; Init VCPU.
    lda #<exec_script
    sta $316
    lda #>exec_script
    sta $317

    jmp patch
