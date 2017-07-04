; Replace decorative sprite by new one.
;
; Y: descriptor of new sprite in sprite_inits
; Returns: A: Index of new sprite or 255 if slots are full.
add_sprite:
    stx add_sprite_x
    sty add_sprite_y

    ldy #@(-- num_sprites)
l:  lda sprite_rr
    and #@(-- num_sprites)
    tax
    inc sprite_rr
    lda sprites_i,x     ; Decorative?
    bmi replace_sprite2 ; Yes…
    dey
    bpl -l

    ldx #255

sprite_added:
    txa
    ldx add_sprite_x
    ldy add_sprite_y
    rts

replace_sprite2:
    txa
    ldy add_sprite_y
    jmp replace_sprite

; Replace sprite by dummy.
;
; X: sprite index
remove_sprite:
    stx add_sprite_x
    sty add_sprite_y

remove_sprite_regs_already_saved:
    ldy #@(- dummy_init sprite_inits)

; Replace sprite by another.
;
; X: sprite index
; Y: low address byte of descriptor of new sprite in sprite_inits
replace_sprite:
    lda #sprites_x          ; Copy descriptor to sprite table.
    sta @(++ +selfmod)
l:  lda sprite_inits,y
selfmod:
    sta sprites_x,x
    iny
    lda @(++ -selfmod)
    cmp #sprites_d
    beq sprite_added
    adc #num_sprites
    sta @(++ -selfmod)
    jmp -l

; Move sprite X up A pixels.
sprite_up:
    jsr neg

; Move sprite X down A pixels.
sprite_down:
    clc
    adc sprites_y,x
    sta sprites_y,x
    rts

; Move sprite X left A pixels.
sprite_left:
    jsr neg

; Move sprite X right A pixels.
sprite_right:
    clc
    adc sprites_x,x
    sta sprites_x,x
    rts

; Test if sprite X is outside the screen.
; Return carry flag set when true.
test_sprite_out:
    lda sprites_x,x
    clc
    adc #8
    cmp #@(* (++ screen_columns) 8)
    bcs +out
    lda sprites_y,x
    clc
    adc #8
    cmp #@(* (++ screen_rows) 8)
out:rts

; Find collision with other sprite.
;
; X: sprite index
;
; Returns:
; C: Clear when a hit was found.
; Y: Sprite index of other sprite.
find_hit:
    stx tmp
    ldy #@(-- num_sprites)

l:  cpy tmp             ; Skip same sprite.
    beq +n
    lda sprites_i,y     ; Skip decorative sprite.
    bmi +n

    lda sprites_x,x     ; Get X distance.
    sec
    sbc sprites_x,y
    jsr abs
    cmp collision_x_distance
    bcs +n             ; Too far off horizontally...

    lda sprites_y,x     ; Get Y distance.
    sec
    sbc sprites_y,y
    jsr abs
    cmp collision_y_distance
    bcc +ok             ; Got one!

n:  dey
    bpl -l
    sec

ok: rts

call_sprite_controllers:
    ; Call the functions that control sprite behaviour.
    ldx #@(-- num_sprites)
l1: lda sprites_fh,x
    sta @(+ +m1 2)
    lda sprites_fl,x
    sta @(++ +m1)
    stx call_controllers_x
    lda #8
    sta collision_x_distance
    sta collision_y_distance
m1: jsr $1234
    ldx call_controllers_x
n1: dex
    bpl -l1
    rts
