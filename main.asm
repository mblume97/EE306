	
	.ORIG x3000
	
; Initialize stack pointer

	LD R6, SP

; Store starting address of ISR in x0180

	LD R0, ISRLOC
	STI R0, IVT

; Enable interrupt by setting the enable bit (bit 14).

	LD R0, SETINT
	STI R0, KBSR

; Main user program

NEXT_LINE
	LD R0, NEWLINE
	OUT
	LD R1, TIMES
MORE_DOTS
	LD R0, DOT
	OUT
	JSR DELAY
	LD R0, SPACE
	OUT
	JSR DELAY
	OUT
	JSR DELAY
	ADD R1, R1, #-1
	BRP MORE_DOTS
	BR NEXT_LINE


; DELAY SUBROUTINE

DELAY
	ST R1, SAVE1
	LD R1, COUNT
AGAIN	ADD R1, R1, #-1
	BRP AGAIN
	LD R1, SAVE1
	RET

SP 	.FILL X3000
ISRLOC 	.FILL X2000
IVT	.FILL x0180
SETINT	.FILL X4000
KBSR	.FILL XFE00
COUNT 	.FILL #2500
SAVE1	.BLKW 1
NEWLINE .FILL X0A
DOT 	.FILL X2E
SPACE 	.FILL X20
TIMES 	.FILL #20

	.END

