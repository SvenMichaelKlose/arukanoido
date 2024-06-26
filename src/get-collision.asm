; Test on collision with foreground char.
;
; A: X position
; Y: Y position
; Returns: Z set if true.
get_soft_collision:
    lsr
    lsr
    lsr
    sta scrx
    tya
    lsr
    lsr
    lsr
    sta scry
get_hard_collision:
    ;jsr scraddr
    ldy scry
    lda line_addresses_l,y
    sta scr
    lda line_addresses_h,y
    sta @(++ scr)
    ldy scrx
    lda (scr),y
    cmp #bg_minivaus    ; Ignore miniature Vaus displaying # of lives.
    beq +n
    and #foreground
n:  rts
