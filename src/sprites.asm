; Replace decorative sprite by new one.
;
; Y: descriptor of new sprite in sprite_inits
; Returns: A: Index of new sprite or 255 if slots are full.
add_sprite:
    stx add_sprite_x
    sty add_sprite_y

    ldy #@(-- num_sprites)
l:  dec sprite_rr
    lda sprite_rr
    and #@(-- num_sprites)
    tax
    lda sprites_i,x     ; Decorative?
    bmi replace_sprite2 ; Yes…
    dey
    bpl -l

    ldx #255

sprite_added:
    txa
r:  ldx add_sprite_x
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
    lda #is_inactive
    sta sprites_i,x
    rts

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

remove_sprites:
    ldx #@(-- num_sprites)
l:  jsr remove_sprite
    dex
    bpl -l
    rts

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
find_hit_tmp:   0
find_hit_tmp2:  0
find_hit_tmp3:  0

find_hit:
    stx find_hit_tmp

    ; Get opposite corner's coordinates of sprite.
    lda sprites_dimensions,x
    and #%111
    asl
    asl
    asl
    clc
    adc sprites_x,x
    sta find_hit_tmp2

    lda sprites_dimensions,x
    and #%111000
    clc
    adc sprites_y,x
    sta find_hit_tmp3

    ldy #@(-- num_sprites)

l:  cpy find_hit_tmp    ; Skip same sprite.
    beq +n

    lda sprites_i,y     ; Skip inactive sprite.
    bmi +n

    lda sprites_x,y
    cmp find_hit_tmp2
    bcs +n
    lda sprites_dimensions,y
    and #%111
    asl
    asl
    asl
    clc
    adc sprites_x,y
    cmp sprites_x,x
    bcc +n

    lda sprites_y,y
    cmp find_hit_tmp3
    bcs +n
    lda sprites_dimensions,y
    and #%111000
    clc
    adc sprites_y,y
    cmp sprites_y,x
    bcc +n

    clc
    rts

find_hit_next:
n:  dey
    bpl -l
    sec

ok: rts

call_sprite_controllers:
    ; Call the functions that control sprite behaviour.
    ldx #@(-- num_sprites)
l1: lda sprites_i,x
    bmi +n1
    lda sprites_fh,x
    sta @(+ +m1 2)
    lda sprites_fl,x
    sta @(++ +m1)
    stx call_controllers_x
m1: jsr $1234
    ldx call_controllers_x
n1: dex
    bpl -l1
    rts
