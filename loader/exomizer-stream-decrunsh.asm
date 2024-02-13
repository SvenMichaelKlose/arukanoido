;
; Copyright (c) 2002, 2003 Magnus Lind.
;
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from
; the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;   1. The origin of this software must not be misrepresented; you must not
;   claim that you wrote the original software. If you use this software in a
;   product, an acknowledgment in the product documentation would be
;   appreciated but is not required.
;
;   2. Altered source versions must be plainly marked as such, and must not
;   be misrepresented as being the original software.
;
;   3. This notice may not be removed or altered from any distribution.
;
;   4. The names of this software and/or it's copyright holders may not be
;   used to endorse or promote products derived from this software without
;   specific prior written permission.
;

decrunch_block_static:
    inc c
    inc @(++ c)
l:  jsr get_decrunched_byte
    ldy #0
    sta (d),y
    inc d
    bne +n
    inc @(++ d)
n:  dec c
    bne -l
    dec @(++ c)
    bne -l
    rts

; -------------------------------------------------------------------
; The decruncher jsr:s to the get_crunched_byte address when it wants to
; read a crunched byte. This subroutine has to preserve x and y register
; and must not modify the state of the carry flag.
; -------------------------------------------------------------------
get_crunched_byte:
    jmp (get_byte)

; -------------------------------------------------------------------
; symbolic names for constants
; -------------------------------------------------------------------
buffer_end_hi = @(+ buffer_start_hi buffer_len_hi)

tabl_bi = decrunch_table
tabl_lo = @(+ decrunch_table 52)
tabl_hi = @(+ decrunch_table 104)
; -------------------------------------------------------------------
; no code below this comment has to be modified in order to generate
; a working decruncher of this source file.
; However, you may want to relocate the tables last in the file to a
; more suitable address.
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; jsr this label to init the decruncher, it will init used zeropage
; zero page locations and the decrunch tables
; no constraints on register content, however the
; decimal flag has to be #0 (it almost always is, otherwise do a cld)
; -------------------------------------------------------------------
init_decruncher:
    sta exo_s
    sty @(++ exo_s)
	jsr get_crunched_byte
	sta zp_bitbuf

	ldx #@(-- buffer_len_hi)
	stx zp_dest_hi
	ldx #@(-- buffer_end_hi)
	stx zp_dest_bi
    lda #buffer_start_hi
	sta zp_src_hi
	sta zp_src_bi
	ldx #0
	stx zp_dest_lo
	stx zp_len_lo
	ldy #0
; -------------------------------------------------------------------
; calculate tables (49 bytes)
; x and y must be #0 when entering
;
_init_nextone:
	inx
	tya
	and #$0f
	beq _init_shortcut		; starta på ny sekvens

	txa			; this clears reg a
	lsr 		; and sets the carry flag
	ldx zp_bits_lo
_init_rolle:
	rol
	rol zp_bits_hi
	dex
	bpl _init_rolle		; c = 0 after this (rol zp_bits_hi)

	adc @(-- tabl_lo),y
	tax

	lda zp_bits_hi
	adc @(-- tabl_hi),y
_init_shortcut:
	sta tabl_hi,y
	txa
	sta tabl_lo,y

	ldx #4
	jsr _bit_get_bits		; clears x-reg.
	sta tabl_bi,y
	iny
	cpy #52
	bne _init_nextone
	rts

; -------------------------------------------------------------------
; decrunch one byte
;
get_decrunched_byte:
    stx exo_x
    sty exo_y

	ldy zp_len_lo
	bne _do_sequence
	ldx #0

	jsr _bit_get_bit1
	beq _get_sequence
	jsr get_crunched_byte
	bcc _do_literal

; -------------------------------------------------------------------
; count zero bits + 1 to get length table index (10 bytes)
; y = x = 0 when entering
;
_get_sequence:
_seq_next1:
	iny
	jsr _bit_get_bit1
	beq _seq_next1
;	cpy #$11
;	bcs _do_exit
; -------------------------------------------------------------------
; calulate length of sequence (zp_len) (17 bytes)
;
	ldx @(-- tabl_bi),y
	jsr _bit_get_bits
	adc @(-- tabl_lo),y
	sta zp_len_lo
	lda @(-- tabl_hi),y
; -------------------------------------------------------------------
; here we decide what offset table to use (20 bytes)
; x is 0 here
;
	bne _seq_nots123
	ldy zp_len_lo
	cpy #$04
	bcc _seq_size123
_seq_nots123:
	ldy #$03
_seq_size123:
	ldx @(-- tabl_bit),y
	jsr _bit_get_bits
	adc @(-- tabl_off),y
	tay
; -------------------------------------------------------------------
; calulate absolute offset (zp_src) (27 bytes)
;
	ldx tabl_bi,y
	jsr _bit_get_bits;
	adc tabl_lo,y
;	bcc _seq_skipcarry
;	inc zp_bits_hi
;	clc
;_seq_skipcarry:
	adc zp_dest_lo
	sta zp_src_lo

_do_sequence:
	ldy #0
	dec zp_len_lo
	dec zp_src_lo
	lda (zp_src_lo),y

_do_literal:
	dec zp_dest_lo
	sta (zp_dest_lo),y
	clc

_do_exit:
    ldx exo_x
    ldy exo_y
	rts

; -------------------------------------------------------------------
; two small static tables (6 bytes)
;
tabl_bit:
	2 4 4
tabl_off:
	48 32 16

; -------------------------------------------------------------------
; get bits (31 bytes)
;
; args:
;   x = number of bits to get
; returns:
;   a = #bits_lo
;   x = #0
;   c = 0
;   zp_bits_lo = #bits_lo
;   zp_bits_hi = #bits_hi
; notes:
;   y is untouched
;   other status bits are set to (a == #0)
; -------------------------------------------------------------------
_bit_get_bits:
	lda #$00
	sta zp_bits_lo
	sta zp_bits_hi
	cpx #$01
	bcc _bit_bits_done
	lda zp_bitbuf
_bit_bits_next:
	lsr
	beq +n
_bit_ok:
	rol zp_bits_lo
	rol zp_bits_hi
	dex
	bne _bit_bits_next
	sta zp_bitbuf
	lda zp_bits_lo
_bit_bits_done:
	rts

n:  jsr get_crunched_byte
	ror
    jmp _bit_ok

_bit_get_bit1:
	stx zp_bits_lo
	lda zp_bitbuf
    lsr
	beq +n
l:  rol zp_bits_lo
	sta zp_bitbuf
	lda zp_bits_lo
	rts

n:  jsr get_crunched_byte
	ror
    jmp -l


; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------
