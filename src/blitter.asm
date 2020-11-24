blit_origin:

if @*rom?*
    org $100
end

; Blit bytes from s to d, shifting them to the right.
;
; In:
; Y: character height
; s: source address
; d: destination address
; blit_right_addr + 1: 7 - bits_to_shift
blit_right:
    sta s
_blit_right_loop:
    lda (s),y
    clc
blit_right_addr:
    bcc +l
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
    lsr
l:  ora (d),y
    sta (d),y
    dey
    bpl _blit_right_loop
    lda @(++ blit_left_addr)
    rts

; Blit bytes from s to d, shifting them to the left.
;
; In:
; Y: character height
; s: source address
; s: destination address
; blit_right_addr + 1: 7 - bits_to_shift
blit_left:
    sta s
_blit_left_loop:
    lda (s),y
    clc
blit_left_addr:
    bcc +l
    asl
    asl
    asl
    asl
    asl
    asl
    asl
    asl
l:  ora (d),y
    sta (d),y
    dey
    bpl _blit_left_loop
    rts

blit_end:

if @*rom?*
    org @(+ blit_origin (- blit_end blit_right))
end
