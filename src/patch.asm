patch:
    jsr init_screen
    jsr clear_screen

    lda #1
    sta curchar
    lda #white
    sta curcol

if @(eq *tv* :pal)
    lda #8
end
if @(eq *tv* :ntsc)
    lda #14
end
    sta scrx2
    lda #14
    sta scry
    lda #<txt_hardware_check
    ldy #>txt_hardware_check
    jsr print_string_ay

if @(eq *tv* :pal)
    lda #1
end
if @(eq *tv* :ntsc)
    lda #7
end
    sta scrx2
    lda #16
    sta scry
    lda #<txt_wait
    ldy #>txt_wait
    jsr print_string_ay

    ; Scan for patch somewhere in memory.
    lda #0
    sta tmp3
    sta tmp4

l:  ldx #@(-- (- id_patch_end id_patch))
    ldy #0
l2: lda (tmp3),y
    cmp id_patch,x
    bne +n
    iny
    dex
    bpl -l2
    ldy #@(++ (- id_patch_end id_patch))
    lda (tmp3),y
    pha
    dey
    lda (tmp3),y
    pha
    rts

n:  inc tmp3
    bne -l
    inc @(++ tmp3)
    bne print_counter

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
    sta @(++ txt_counter)

m:  lda $9004
    lsr
    bne -m

    lda #128
    sta curchar
if @(eq *tv* :pal)
    lda #14
end
if @(eq *tv* :ntsc)
    lda #20
end
    sta scrx2
    lda #18
    sta scry
    lda #<txt_counter
    ldy #>txt_counter
    jsr print_string_ay

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
txt_wait:           @(string4x8 "WAIT UNTIL TIMER REACHES '0'") 255
txt_counter:        @(string4x8 "0") 0 255
