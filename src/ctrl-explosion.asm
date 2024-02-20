replace_by_explosion:
    lda #0              ; (decorative sprite)
    sta sprites_i,x
    sta sprites_pgl,x
    sta sprites_pgh,x
    lda sprites_x,x
    and #$fe            ; (to multi-color X)
    sta sprites_x,x
    lda #<gfx_explosion
    sta sprites_gl,x
    lda #>gfx_explosion
    sta sprites_gh,x
    lda #@(+ multicolor yellow)
    sta sprites_c,x
    lda #<ctrl_explosion
    sta sprites_fl,x
    lda #>ctrl_explosion
    sta sprites_fh,x
r:  rts

ctrl_explosion:
    ; Every four frames only.
    lda framecounter
    and #3
    bne -r

    ; Step to next frame of animation.
    lda sprites_gl,x
    clc
    adc #16
    sta sprites_gl,x
    bcc +n
    inc sprites_gh,x

    ; End of animation.
n:  cmp #<gfx_explosion_end
    bne -r
    jmp remove_sprite
