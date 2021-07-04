; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.

.include "music.h"
.segment "CODE"

;-----------------------
;Music routine variables

; Readonly values
sndbase = $900a
volumereg = $900e
volumeregmask = %11110000
VOICE_COUNT = 4
PLAYER_COUNT = 2


; song Indexes
songindexes:
.byte 0

.repeat 12 , lc
	.byte   (PLAYER_COUNT * VOICE_COUNT * lc)
.endrepeat

.repeat 12 , lc
	.byte   (PLAYER_COUNT * VOICE_COUNT * (12 + lc))
.endrepeat

.repeat 8 , lc
	.byte   (PLAYER_COUNT * VOICE_COUNT * (24 + lc))
.endrepeat



; controlValues
noteControlLower: .byte 0, VOICE_COUNT
noteControlUpper: .byte VOICE_COUNT, PLAYER_COUNT * VOICE_COUNT 
curPlayerMaskArray: .byte $0,$FF

; per player temp values
curPlayer:    .byte  0
curPlayerMask: .byte 0
curNoteControlLower: .byte 0
curNoteControlUpper: .byte 0

;Variables for notecontrol per player (effects are also short songs!)
curSong:			.res PLAYER_COUNT, 0
reqSong:			.res PLAYER_COUNT, 0

;Variables for notecontrol
returnIdx: 			.res PLAYER_COUNT * VOICE_COUNT, 0
pos: 				.res  PLAYER_COUNT * VOICE_COUNT, 0
delay: 				.res PLAYER_COUNT * VOICE_COUNT, 1
delaybase: 			.res PLAYER_COUNT * VOICE_COUNT, 1

;Other music routine variables
volfademode: 		.byte 0
volfadespd:  		.byte 0
activeSong: 		.byte 0
curVoiceMask: 		.byte 0

; zero page usage
zp =  $FC
zp2 = $FE

domusic:	
	
	
	; music first overlaid with effects
	lda #0
	sta curPlayer
	
ProcessPlayer:

	 ldx curPlayer
	 
	 ; init working vars
	 lda noteControlLower, x
	 sta curNoteControlLower
	 
	 lda noteControlUpper, x
	 sta curNoteControlUpper
	 
	 lda curPlayerMaskArray,x
	 sta curPlayerMask
	 
	 lda reqSong,x
	 cmp #255
	 beq @playSong
     sta curSong,x	 
	 lda #255
	 sta reqSong,x
		
@changeSong:

	; Player 0
	ldy curSong + 0
	lda ActiveVoicesBase,y
	sta zp2	
	
	; Player 1
	ldy curSong + 1
	lda ActiveVoicesBase,y
	ora zp2

	; Switch off unused voices
	ldy #0
	lsr
	bcs @v2
@v11:	
	sty sndbase
@v2:
	lsr
	bcs @v3
	sty sndbase + 1
@v3:
	lsr
	bcs @v4
	sty sndbase + 2
@v4:
	lsr
	bcs @done
	sty sndbase	+ 3

@done:

	; reset positions of players voices when changins the effect of song
	ldx curPlayer
	ldy curNoteControlLower

@loop2:	 
	
	lda #0
	sta pos,y
	lda #1
	sta delaybase,y
	sta delay,y
	iny
	cpy curNoteControlUpper
	bne @loop2

@playSong:

	 ; dont play song 0
	 lda curSong, x
	 sta activeSong
	 bne @action
	 jmp nextPlayer

@action:	 
	 
      ;Volume and volume fade control:
	  lda #1
	  sta curVoiceMask	
	  lda volfademode
	  beq nofade
	  dec volfademode
	  bne nofade
	  dec volumereg
	  lda volumereg
	  and #(volumeregmask ^ 255)
	  beq fadedone
	  lda volfadespd


fadedone:
	
		sta volfademode

nofade:

		;Process each voice:
		ldx curNoteControlLower

processDelay:

		; delay not expired so process the note
		ldy activeSong
		lda ActiveVoicesBase,y
		and curVoiceMask
		beq nextVoice
		
		dec delay,x		;Are we done with the current note?
		bne nextVoice

		txa
		clc
		adc songindexes,y
		tay
		
		bit curPlayerMask
		bmi @effect
@music:
		lda SongBaseLO,y
		sta zp
		lda SongBaseHI,y
		bpl @cont
@effect:
		lda SongBaseLO - VOICE_COUNT,y
		sta zp
		lda SongBaseHI - VOICE_COUNT,y
@cont:
		beq nextVoice
		sta zp+1
		ldy pos,x

next2:

		lda (zp),y
		iny		; no check for page boundaries (tunes < 256 bytes)

		cmp #firstcode
			bcs noduration
			sta delaybase,x
			bcc next2	;branch always

noduration:
		
		cmp #silencecode	;Is it a note or silence?
			bcs realnote
		cmp #setvolcode
			beq processsetvol
		cmp #volfadecode
			beq processfadevol
		cmp #chaincode
			beq processchaincode
		cmp #stopcode
			beq processstopcode
		cmp #nullcode			
			beq delayOnly
		cmp #returncode	
			beq ProcessReturn
		cmp #gotocode		;default case: goto command
			bne unknown
			tya
			sta returnIdx, x
			lda (zp),y
			tay
			jmp next2		;and read from there
unknown:			
			brk

notsilence:
			
realnote:		;note or silence
		
		bit curPlayerMask
		bmi @effect
@music:
		sta sndbase , x
		bpl @cont
@effect:
		sta sndbase - VOICE_COUNT,x
@cont:
delayOnly:
		lda delaybase,x
		sta delay,x
		tya
		sta pos,x

nextVoice:
		asl curVoiceMask
		inx
		cpx curNoteControlUpper
		beq nextPlayer
		jmp processDelay
		
nextPlayer:
		
		inc curPlayer
		lda curPlayer
		cmp #PLAYER_COUNT
		beq exit
		jmp ProcessPlayer

exit:

		rts
		

  ;Process fade volume
  ;-------------------

processfadevol:
	  
	  lda (zp),y
	  sta volfadespd
	  sta volfademode
	  jmp donext

  ;ProcessChain Code
processchaincode:
    lda (zp),y
	jmp doprocessstopcode
  
  ;Process set volume
  ;------------------

processsetvol:
	  lda volumereg
	  and #volumeregmask
      ora (zp),y
	  sta volumereg
donext:
	  iny
	  beq @cont
	  jmp next2	;branch always (tunes < 256 bytes)
@cont:
processstopcode:
	lda #0

doprocessstopcode:
	ldx curPlayer
	sta reqSong,x
	jmp nextPlayer

ProcessReturn:
			ldy returnIdx, x
			jmp next2	

	
;Music-data
;----------

.include "allmusic.mus"

initmusic:	; initialize the music
  
  lda #0
  sta sndbase 	; disable channels 0-2
  sta sndbase + 1; disable channels 0-2
  sta sndbase + 2	; disable channels 0-2
  sta sndbase + 3	; disable channels 0-2
  sta reqSong
  sta reqSong + 1
  rts
  
