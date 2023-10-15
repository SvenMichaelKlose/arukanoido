if @(not *rom?*)
    fill @(- #x1b00 *pc*)
end

patch:
    jsr init_screen
    jsr clear_screen

    ldx #0
    stx has_3k
    sta has_24k
    stx has_digis
    lda #$5e
    sta bricks2

    ; Detect RAM123.
    ldx #2
    ldy $0400
l:  stx $0400
    cpx $0400
    bne +n
    dex
    bne -l
    inc has_3k
n:  sty $0400

    ; Detect BLK3.
    ldx #2
    ldy $6000
l:  stx $6000
    cpx $6000
    bne +n
    dex
    bne -l
    inc has_24k
    lda #$1e
    sta bricks2
n:  sty $a000

    ; Detect BLK5.
    ldx #2
    ldy $a000
l:  stx $a000
    cpx $a000
    bne +n
    dex
    bne -l
    inc has_digis
    lda #$be
    sta bricks2
n:  sty $a000
m:

    ldx #2
l:  lda txt_counter,x
    sta txt_tmp,x
    dex
    bpl -l

    ;; Print counter headers.
    lda #1
    sta curchar
    lda #white
    sta curcol

    lda #14
    ldy is_landscape
    bne +n
    lda #8
n:  sta scrx2
    lda #14
    sta scry
    lda #<txt_hardware_check
    ldy #>txt_hardware_check
    jsr print_string_ay

    lda #6
    ldy is_landscape
    bne +n
    lda #0
n:  sta scrx2
    lda #16
    sta scry
    lda #<txt_wait
    ldy #>txt_wait
    jsr print_string_ay

    ;; Scan for patch all across the address space.
    ; Start at $0000.
    lda #0
    sta tmp3
    sta tmp4
    ; Compare pointer to ID string.
l:  ldx #@(-- (- id_patch_end id_patch))
    ldy #0
l2: lda (tmp3),y
    cmp id_patch,x
    bne +n
    iny
    dex
    bpl -l2
    ; Call patch.
    ldy #@(++ (- id_patch_end id_patch))
    lda (tmp3),y
    pha
    dey
    lda (tmp3),y
    pha
    rts
    ; Step to next byte.
n:  inc tmp3
    bne -l
    inc @(++ tmp3)
    ; Re-print counter on each new page.
    bne print_counter

    ; No patch found.  Do regular start.
    jmp start

print_counter:
    txa
    pha
    tya
    pha

    lda @(++ tmp3)
    lsr
    lsr
    lsr
    lsr
    lsr
    sta tmp
    lda #7
    sec
    sbc tmp
    adc #@(- (char-code #\0) 32)
    sta @(++ txt_tmp)

    ; Wait for retrace.
m:  lda $9004
    lsr
    bne -m

    lda #128
    sta curchar
    lda #20
    ldy is_landscape
    bne +n
    lda #14
n:  sta scrx2
    lda #18
    sta scry
    lda #<txt_tmp
    ldy #>txt_tmp
    jsr print_string_ay

    ; Start game on user break.
    jsr test_fire
    beq +r
    jsr poll_keypress
    bcc +n
r:  jsr wait_fire_released
    jsr wait_keyunpress
    ldx #$ff
    txs
    jmp start

n:  pla
    tay
    pla
    tax
    jmp -l

id_patch:           @(make-reverse-patch-id)
id_patch_end:
txt_hardware_check: @(string4x8 "HARDWARE CHECK") 255
txt_wait:           @(string4x8 " WAIT UNTIL TIMER REACHES '0'") 255
txt_counter:        @(string4x8 "0") 0 255
