.include "music.h"
.segment "CODE"

; Globals--------------------------------------------------------------------
.global RESTART
.global Charset
.global CharNumBase
.global CharAlphaBase
LASTKEY  = 197

keycodes: .byte 60,0,56,1,57,2,58,3,59,4,48,9,49,10,50,11,51,12,52,13
		  .byte 17,41,18,42,19,43,20,44,21,45,22,46
		  .byte 33,26,34,27,35,28,36,29,37,30
keycodes_last:
lastKeyPressed: .byte  0;


; ------------------------------ Entry Point---------------------

RESTART:
								jsr InitSoundAndVideo
LOOP:
								ldx #MAXSONG-1
								lda LASTKEY 
@loopKeyMatch:
								cmp #32
								beq RESTART
								cmp keycodes,x 
								beq matched
								dex
								bne @loopKeyMatch
								jmp LOOP
matched:							
								inc 36879
								stx reqSong
								jmp LOOP

; ------------------------------PlaySongBlocking ---------------------

IrqHandler:
								jsr domusic
								JMP $EABF

; ------------------------------ InitSoundAndVideo -----------------------------
InitSoundAndVideo:
								; Init music player
								jsr initmusic
								
                                ; Setup IRQ to our own handler which chains the SSS
                                SEI
                                LDX #<IrqHandler                ; allows for tear-free flipping
                                LDY #>IrqHandler
                                STX $0314
                                STY $0315
                                CLI
								rts
		
