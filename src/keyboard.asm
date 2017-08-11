keycode_a  = $2e
keycode_b  = $1c
keycode_c  = $1d
keycode_d  = $2d
keycode_e  = $0e
keycode_f  = $15
keycode_g  = $2c
keycode_h  = $14
keycode_i  = $33
keycode_j  = $2b
keycode_k  = $13
keycode_l  = $2a
keycode_m  = $1b
keycode_n  = $23
keycode_o  = $0b
keycode_p  = $32
keycode_q  = $0f
keycode_r  = $35
keycode_s  = $16
keycode_t  = $0d
keycode_u  = $0c
keycode_v  = $24
keycode_w  = $36
keycode_x  = $25
keycode_y  = $34
keycode_z  = $1e

keycode_0  = $03
keycode_1  = $3f
keycode_2  = $07
keycode_3  = $3e
keycode_4  = $06
keycode_5  = $3d
keycode_6  = $05
keycode_7  = $3c
keycode_8  = $04
keycode_9  = $3b

keycode_enter  = $60
keycode_space  = $37

via2_portb0 = $9120
via2_porta0 = $9121

wait_keyunpress:
    lda #0
    sta via2_portb0
    lda via2_porta0
    cmp #$ff
    bne wait_keyunpress
    rts

get_keypress:
    lda #255            ; Set port B to output.
    sta $9122
    lda #0
    sta $9123           ; Set port A to input.
    sta via2_portb0
    lda via2_porta0
    cmp via2_porta0
    bne get_keypress
    cmp #$ff
    beq no_keypress

    ldy #7              ; Keyboard column bitmask index.
next_column:
    ldx #7              ; Row bit count.
    lda columnbits,y
    sta via2_portb0

    lda via2_porta0
next_row:
    lsr
    bcc got_row

    dex
    bpl next_row

    dey
    bpl next_column

no_keypress:
    clc
    rts

got_row:
    stx tmp
    tya
    asl
    asl
    asl
    ora tmp
    sec
    rts

poll_keypress:
    jsr get_keypress
    bcs +l
    rts

wait_keypress:
    jsr get_keypress
    bcc wait_keypress
l:  pha
    jsr wait_keyunpress
    pla
    sec
    rts

columnbits:
    %01111111
    %10111111
    %11011111
    %11101111
    %11110111
    %11111011
    %11111101
    %11111110