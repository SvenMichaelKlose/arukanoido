;*********************************************************************
; COMMODORE VIC 20 BOOT USING BASIC 2.0
; written by Robert Hurst <robert@hurst-ri.us>
; updated version: 31-Oct-2010
;
		.fileopt author,	"your name"
        .fileopt comment,	"your program name"
        .fileopt compiler,	"VIC 20 ASSEMBLER"
		.global Charset
		
VIC			= $9000		; start of Video Interface Chip registers
MACHINE		= $EDE4		; NTSC=$05, PAL=$0C
RESET		= $FD22		; warm startup

		;*********************************************************************
; Commodore BASIC 2.0 program
;
; LOAD "YOUR PROGRAM.PRG",8
; RUN
;
		.segment "BASIC"

		.word	RUN		; load address
RUN:	.word	@end	; next line link
		.word	2010	; line number
		.byte	$9E		; BASIC token: SYS
		.byte	<(MAIN / 1000 .mod 10) + $30
		.byte	<(MAIN / 100 .mod 10) + $30
		.byte	<(MAIN / 10 .mod 10) + $30
		.byte	<(MAIN / 1 .mod 10) + $30
		.byte	0		; end of line
@end:	.word	0		; end of program

;*********************************************************************
; Starting entry point for this program
;
		.segment "STARTUP"

MAIN:
		LDX $FFFC
		LDY $FFFD
		STX $0318
		STY $0319		; enable RESTORE key as RESET
		LDA MACHINE
		CMP #$05
		BEQ NTSC
		CMP #$0C
		BEQ PAL
READY:	JMP RESET		; not a VIC?
		;
		; NTSC setup
NTSC:	LDX #<@NTSC		; load the timer low-byte latches
		STX $9126
		LDX #>@NTSC
		LDA #$75		; raster line 234/235
		BNE IRQSYNC
@NTSC = $4243			; (261 * 65 - 2)
		;
		; PAL setup
PAL:	LDX #<@PAL		; load the timer low-byte latches
		STX $9126
		LDX #>@PAL
		LDA #$82		; raster line 260/261
		BNE IRQSYNC
@PAL = $5686			; (312 * 71 - 2)
		;
IRQSYNC:
		CMP $9004
		BNE IRQSYNC
		STX $9125		; load T1 latch high, and transfer both bytes to T1 counter


		temp_ptr = $A7 
		temp_ptr2 = temp_ptr + 2

;*********************************************************************
; Now that all the VIC startup initialization stuff is completed,
; you can append one-time startup code/data here, i.e., like a splash
; title screen.  Then, you must jump to your CODE segment, linked
; outside of VIC's internal RAM address space ...
;
RUNONCE:

		;
		;====  INSERT ANY ADDITIONAL STARTUP CODE HERE  ====
		;
		
		; One time generation of UDC chars moved to main program as needed multiple times
		JMP BEGIN
		

		
;*********************************************************************
; Your main program code starts here
;
		.segment "CODE"

BEGIN:
		.global RESTART
		jmp RESTART
