;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	description: 	Connect 4 game!				;
;								;
; 								;
;	file:		connect4_start.asm			;
;	This is the starter code for the Connect4 game		;
;								;
;	author:		Birgi Tamersoy/Nina Telang		;
;	date:		04/09/2013				;
;		update:	04/10/2013 -> finished & tested.	;
;		update: 04/12/2013 -> re-arranged for students.	;
;				   -> added 2nd dia. check.	;
;								;	
;		update: 11/05/15				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Main Program						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JSR INIT
ROUND
	JSR DISPLAY_BOARD
	JSR GET_MOVE
	JSR UPDATE_BOARD
	JSR UPDATE_STATE

	ADD R6, R6, #0
	BRz ROUND

	JSR DISPLAY_BOARD
	JSR GAME_OVER

	HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Functions & Constants!!!				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_TURN						;
;	description:	Displays the appropriate prompt.	;
;	inputs:		None!					;
;	outputs:	None!					;
;	assumptions:	TURN is set appropriately!		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_TURN
	ST R0, DT_R0
	ST R7, DT_R7

	LD R0, TURN
	ADD R0, R0, #-1
	BRp DT_P2
	LEA R0, DT_P1_PROMPT
	PUTS
	BRnzp DT_DONE
DT_P2
	LEA R0, DT_P2_PROMPT
	PUTS

DT_DONE

	LD R0, DT_R0
	LD R7, DT_R7

	RET
DT_P1_PROMPT	.stringz 	"Player 1, choose a column: "
DT_P2_PROMPT	.stringz	"Player 2, choose a column: "
DT_R0		.blkw	1
DT_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GET_MOVE						;
;	description:	gets a column from the user.		;
;			also checks whether the move is valid,	;
;			or not, by calling the CHECK_VALID 	;
;			subroutine!				;
;	inputs:		None!					;
;	outputs:	R6 has the user entered column number!	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET_MOVE
	ST R0, GM_R0
	ST R7, GM_R7

GM_REPEAT
	JSR DISPLAY_TURN
	GETC
	OUT
	JSR CHECK_VALID
	LD R0, ASCII_NEWLINE
	OUT

	ADD R6, R6, #0
	BRp GM_VALID

	LEA R0, GM_INVALID_PROMPT
	PUTS
	LD R0, ASCII_NEWLINE
	OUT
	BRnzp GM_REPEAT

GM_VALID

	LD R0, GM_R0
	LD R7, GM_R7

	RET
GM_INVALID_PROMPT 	.stringz "Invalid move. Try again."
GM_R0			.blkw	1
GM_R7			.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_BOARD						;
;	description:	updates the game board with the last 	;
;			move!					;
;	inputs:		R6 has the column for last move.	;
;	outputs:	R5 has the row for last move.		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_BOARD
	ST R1, UP_R1
	ST R2, UP_R2
	ST R3, UP_R3
	ST R4, UP_R4
	ST R6, UP_R6
	ST R7, UP_R7

	; clear R5
	AND R5, R5, #0
	ADD R5, R5, #6

	LEA R4, ROW6
	
UB_NEXT_LEVEL
	ADD R3, R4, R6

	LDR R1, R3, #-1
	LD R2, ASCII_NEGHYP

	ADD R1, R1, R2
	BRz UB_LEVEL_FOUND

	ADD R4, R4, #-7
	ADD R5, R5, #-1
	BRnzp UB_NEXT_LEVEL

UB_LEVEL_FOUND
	LD R4, TURN
	ADD R4, R4, #-1
	BRp UB_P2

	LD R4, ASCII_O
	STR R4, R3, #-1

	BRnzp UB_DONE
UB_P2
	LD R4, ASCII_X
	STR R4, R3, #-1

UB_DONE		

	LD R1, UP_R1
	LD R2, UP_R2
	LD R3, UP_R3
	LD R4, UP_R4
	LD R6, UP_R6
	LD R7, UP_R7

	RET
ASCII_X	.fill	x0058
ASCII_O	.fill	x004f
UP_R1	.blkw	1
UP_R2	.blkw	1
UP_R3	.blkw	1
UP_R4	.blkw	1
UP_R5	.blkw	1
UP_R6	.blkw	1
UP_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHANGE_TURN						;
;	description:	changes the turn by updating TURN!	;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHANGE_TURN
	ST R0, CT_R0
	ST R1, CT_R1
	ST R7, CT_R7

	LD R0, TURN
	ADD R1, R0, #-1
	BRz CT_TURN_P2

	ST R1, TURN
	BRnzp CT_DONE

CT_TURN_P2
	ADD R0, R0, #1
	ST R0, TURN

CT_DONE
	LD R0, CT_R0
	LD R1, CT_R1
	LD R7, CT_R7

	RET
CT_R0	.blkw	1
CT_R1	.blkw	1
CT_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_WINNER						;
;	description:	checks if the last move resulted in a	;
;			win or not!				;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNER
	ST R5, CW_R5
	ST R6, CW_R6
	ST R7, CW_R7

	AND R4, R4, #0
	
	JSR CHECK_HORIZONTAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_VERTICAL
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_DIAGONALS

CW_DONE

	LD R5, CW_R5
	LD R6, CW_R6
	LD R7, CW_R7

	RET
CW_R5	.blkw	1
CW_R6	.blkw	1
CW_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_STATE						;
;	description:	updates the state of the game by 	;
;			checking the board. i.e. tries to figure;
;			out whether the last move ended the game;
; 			or not! if not updates the TURN! also	;
;			updates the WINNER if there is a winner!;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R6 has  1, if the game is over,		;
;				0, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_STATE
	ST R0, US_R0
	ST R1, US_R1
	ST R4, US_R4
	ST R7, US_R7
	
	; checking if the last move resulted in a win or not!
	JSR CHECK_WINNER
	
	ADD R4, R4, #0
	BRp US_OVER
	
	; checking if the board is full or not!
	AND R6, R6, #0
		
	LD R0, NBR_FILLED
	ADD R0, R0, #1
	ST R0, NBR_FILLED

	LD R1, MAX_FILLED
	ADD R1, R0, R1
	BRz US_TIE

US_NOT_OVER
	JSR CHANGE_TURN
	BRnzp US_DONE

US_OVER
	ADD R6, R6, #1
	LD R0, TURN
	ST R0, WINNER
	BRnzp US_DONE

US_TIE
	ADD R6, R6, #1

US_DONE
	LD R0, US_R0
	LD R1, US_R1
	LD R4, US_R4
	LD R7, US_R7

	RET
NBR_FILLED	.fill	#0
MAX_FILLED	.fill	#-36
US_R0		.blkw	1
US_R1		.blkw	1
US_R4		.blkw	1
US_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	INIT							;
;	description:	simply sets the BOARD_PTR appropriately!;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT
	ST R0, I_R0
	ST R7, I_R7

	LEA R0, ROW1
	ST R0, BOARD_PTR

	LD R0, I_R0
	LD R7, I_R7

	RET
I_R0	.blkw	1
I_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Global Constants!!!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_SPACE	.fill		x0020				;
ASCII_NEWLINE	.fill		x000A				;
TURN		.fill		1				;
WINNER		.fill		0				;
								;
ASCII_OFFSET	.fill		x-0030				;
ASCII_NEGONE	.fill		x-0031				;
ASCII_NEGSIX	.fill		x-0036				;
ASCII_NEGHYP	.fill	 	x-002d				;
								;
ROW1		.stringz	"------"			;
ROW2		.stringz	"------"			;
ROW3		.stringz	"------"			;
ROW4		.stringz	"------"			;
ROW5		.stringz	"------"			;
ROW6		.stringz	"------"			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;DO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;CHANGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ANYTHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ABOVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;THIS!!!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_BOARD						;
;	description:	Displays the board.			;
;	inputs:		None!					;
;	outputs:	None!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_BOARD
	
	ST R0, SAVE0
	ST R1, SAVE1
	ST R2, SAVE2
	ST R3, SAVE3
	ST R4, SAVE4
	ST R7, SAVE711 

	AND R1, R1, #0
	ADD R1, R1, #6

	LD R2, BOARD_PTR
	
DIS_AGAIN
	LDR R0, R2, #0 
	BRZ NT_LINE 
	OUT
	LD R0, SPACE
	OUT
	BR NT_CHAR

NT_LINE	
	LD R0, NEXT_LINE
	OUT
	ADD R1, R1, #-1
	BRZ END_DIS

NT_CHAR
	ADD R2, R2, #1
	BR DIS_AGAIN
	
END_DIS	
	LD R0, SAVE0
	LD R1, SAVE1
	LD R2, SAVE2
	LD R3, SAVE3
	LD R4, SAVE4
	LD R7, SAVE711
	RET
SAVE0 		.BLKW 1
SAVE1 		.BLKW 1
SAVE2 		.BLKW 1
SAVE3 		.BLKW 1
SAVE4 		.BLKW 1
SAVE5 		.BLKW 1
SAVE6 		.BLKW 1
SAVE711		.BLKW 1
SPACE 		.FILL x20
NEXT_LINE	.FILL x0A


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GAME_OVER						;
;	description:	checks WINNER and outputs the proper	;
;			message!				;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GAME_OVER

	ST R0, SAVE0
	ST R1, SAVE1
	ST R2, SAVE2
	
	LD R0, WINNER
	BRZ NO_WINNER
	ADD R1, R0, #-1 
	BRZ P1_WINS
	BR P2_WINS 

P1_WINS
	LEA R0, P1_WINS_MESSAGE
	PUTS
	BR STOP 

P2_WINS
	LEA R0, P2_WINS_MESSAGE
	PUTS
	BR STOP 

	LD R0, SAVE0
	LD R1, SAVE1
	LD R2, SAVE2

NO_WINNER
	LD R1, NBR_FILLED
	BRZ NOT_DONE_YET
	LEA R0, TIE
	PUTS

STOP 	HALT

NOT_DONE_YET
	RET

P1_WINS_MESSAGE .STRINGZ "Player 1 Wins."
P2_WINS_MESSAGE .STRINGZ "Player 2 Wins."
TIE    		.STRINGZ "Tie Game."
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VALID						;
;	description:	checks whether a move is valid or not!	;
;	inputs:		R0 has the ASCII value of the move!	;
;	outputs:	R6 has:	0, if invalid move,		;
;				decimal col. val., if valid.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VALID
	
	ST R0, SAVE0
	ST R1, SAVE1
	ST R2, SAVE2
	ST R3, SAVE3
	ST R4, SAVE4
	ST R5, SAVE5

	LD R1, ASCII_1
	LD R2, NEG_6

	ADD R3, R0, R1
	BRN N_VALID
	ADD R3, R0, R2
	BRP N_VALID

	LEA R4, ROW1 
	LD R5, ASCII_OFFSET
	ADD R3, R0, R5
	ADD R3, R3, #-1
	ADD R5, R4, R3
	LDR R2, R5, #0
	LD R3, ASCII_NEGHYP
	ADD R1, R2, R3
	BRZ VALID
	BR N_VALID
	
N_VALID	
	AND R6, R6, #0
	BR DONE_CHECKVA

VALID
	AND R6, R6, #0
	LD R5, ASCII_OFFSET	
	ADD R4, R0, R5
	ADD R6, R6, R4

DONE_CHECKVA
	LD R0, SAVE0
	LD R1, SAVE1
	LD R2, SAVE2
	LD R3, SAVE3
	LD R4, SAVE4
	LD R5, SAVE5
	RET
ASCII_1 .FILL x-31
NEG_6	.FILL X-36

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;USE THE FOLLOWING TO ACCESS THE BOARD!!!;;;;;;;;;;;;;;;;;;
;;;;;IT POINTS TO THE FIRST ELEMENT OF ROW1 (TOP-MOST ROW)!!!;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BOARD_PTR	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_HORIZONTAL					;
;	description:	horizontal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_HORIZONTAL

	ST R0, SAVE0
	ST R1, SAVE1
	ST R2, SAVE2	
	ST R3, SAVE3	; COUNTER
	ST R5, SAVE5
	ST R6, SAVE6


	ADD R6, R6, #-1 ; COLUMN - 1
	ADD R5, R5, #-1 ; ROW - 1
	
			; MUTIPLY ROW BY 6
	AND R1, R1, #0
	ADD R1, R1, #6
	AND R2, R2, #0 ; will contain the product of row times 6
MULT	
	ADD R2, R2, R5
	ADD R1, R1, #-1
	BRP MULT

	ADD R1, R2, R5 ; ROW TIMES 6 PLUS ROW
	ADD R2, R1, R6 ; ROW TIMES 6 PLUS ROW PLUS COL
	LD R0, BOARD_PTR
	ADD R4, R2, R0 ; ROW TIMES 6 PLUS ROW PLUS COL PLUS BOARD POINTER (THIS IS POSITION OF LAST MOVE!!!)
	ST R4, LAST_MVE 

; NOW HAVE TO CHECK HORIZONTAL BY GOING TO THE LEFT AND RIGHT AND KEEPING A CONUNTER

	AND R3, R3, #0
	ADD R3, R3, #1	; MAKE THE COUNTER ONE INITALLY BECAUSE OF THE FIRST MOVE
	

HOR_LEFT
	ADD R4, R4, #-1 ; CHECK TO THE LEFT FIRST
	LDR R0, R4, #0 ; GET THE PIECE TO THE LEFT OF THE CURRENT MOVE IN R0

	LD R2, TURN
	ADD R1, R2, #-1    
	BRZ HOR_PLAYER1_CHECK_LEFT
	BR HOR_PLAYER2_CHECK_LEFT	

HOR_PLAYER1_CHECK_LEFT
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ HOR_LEFT_MATCH
	LD R4, LAST_MVE
	BR HOR_RIGHT

HOR_PLAYER2_CHECK_LEFT
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ HOR_LEFT_MATCH
	LD R4, LAST_MVE
	BR HOR_RIGHT

HOR_LEFT_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR HOR_LEFT ; CHECK LEFT AGAIN

HOR_RIGHT
	ADD R4, R4, #1  ; CHECK TO THE RIGHT NOW ONCE THERE IS NO MORE MATCH
	LDR R0, R4, #0 	; GET THE PIECE TO THE RIGHT OF THE CURRENT MOVE IN R0
	
	LD R2, TURN
	ADD R1, R2, #-1    
	BRZ HOR_PLAYER1_CHECK_RIGHT
	BR HOR_PLAYER2_CHECK_RIGHT

HOR_PLAYER1_CHECK_RIGHT
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ HOR_RIGHT_MATCH
	BR CHECK_HOR_WINNER

HOR_PLAYER2_CHECK_RIGHT
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ HOR_RIGHT_MATCH
	BR CHECK_HOR_WINNER

HOR_RIGHT_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR HOR_RIGHT ; CHECK RIGHT AGAIN
	
CHECK_HOR_WINNER
	ADD R3, R3, #-4
	BRZP HOR_WIN
	BR HOR_LOSE
	
HOR_LOSE	
	AND R4, R4, #0	
	BR HOR_DONE

HOR_WIN 
	AND R4, R4, #0
	ADD R4, R4, #1
	
HOR_DONE
	LD R0, SAVE0
	LD R1, SAVE1
	LD R2, SAVE2
	LD R3, SAVE3
	LD R5, SAVE5
	LD R6, SAVE6
	
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VERTICAL						;
;	description:	vertical check.				;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VERTICAL
	
	ST R0, SAVE0
	ST R1, SAVE1
	ST R2, SAVE2	
	ST R3, SAVE3	; COUNTER
	ST R5, SAVE5
	ST R6, SAVE6


; NOW HAVE TO CHECK VERTICAL BY GOING UP AND DOWN AND KEEPING A CONUNTER

	AND R3, R3, #0
	ADD R3, R3, #1	; MAKE THE COUNTER ONE INITALLY BECAUSE OF THE FIRST MOVE
	LD R4, LAST_MVE

VER_UP
	ADD R4, R4, #-7 ; CHECK GOING UP FIRST
	LDR R0, R4, #0 ; GET THE PIECE ABOVE OF THE CURRENT MOVE IN R0

	LDI R2, TURN_MEM
	ADD R1, R2, #-1    
	BRZ VER_PLAYER1_CHECK_UP
	BR VER_PLAYER2_CHECK_UP	

VER_PLAYER1_CHECK_UP
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ VER_UP_MATCH
	LD R4, LAST_MVE
	BR VER_DOWN

VER_PLAYER2_CHECK_UP
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ VER_UP_MATCH
	LD R4, LAST_MVE
	BR VER_DOWN

VER_UP_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR VER_UP ; CHECK LEFT AGAIN

VER_DOWN 
	ADD R4, R4, #7  ; CHECK BELOW NOW ONCE THERE IS NO MORE MATCH
	LDR R0, R4, #0 	; GET THE PIECE BELOW OF THE CURRENT MOVE IN R0
	
	LDI R2, TURN_MEM
	ADD R1, R2, #-1    
	BRZ VER_PLAYER1_CHECK_DOWN
	BR VER_PLAYER2_CHECK_DOWN

VER_PLAYER1_CHECK_DOWN
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ VER_DOWN_MATCH
	BR CHECK_VER_WINNER

VER_PLAYER2_CHECK_DOWN
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ VER_DOWN_MATCH
	BR CHECK_VER_WINNER

VER_DOWN_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR VER_DOWN ; CHECK RIGHT AGAIN

CHECK_VER_WINNER
	ADD R3, R3, #-4
	BRZP VER_WIN
	BR VER_LOSE
	
VER_LOSE	
	AND R4, R4, #0	
	BR VER_DONE

VER_WIN 
	AND R4, R4, #0
	ADD R4, R4, #1
	
VER_DONE
	LD R0, SAVE0
	LD R1, SAVE1
	LD R2, SAVE2
	LD R3, SAVE3
	LD R5, SAVE5
	LD R6, SAVE6

	RET
LAST_MVE .BLKW 1
ASCII_P2X  .FILL x-0058
ASCII_P1O  .FILL x-004f

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_DIAGONALS						;
;	description:	checks diagonals by calling 		;
;			CHECK_D1 & CHECK_D2.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DIAGONALS

	ST R0, SAVE0
	ST R1, SAVE1
	ST R2, SAVE2	
	ST R3, SAVE3
	ST R5, SAVE5
	ST R6, SAVE6
	ST R7, SAVE7

	JSR CHECK_D1
	
	ADD R4, R4, #0
	BRP WINNER_ALREADY
	
	JSR CHECK_D2

WINNER_ALREADY
	LD R0, SAVE0
	LD R1, SAVE1
	LD R2, SAVE2
	LD R3, SAVE3
	LD R5, SAVE5
	LD R6, SAVE6
	LD R7, SAVE7

	RET
SAVE7 .BLKW 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D1						;
;	description:	1st diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D1

	ST R0, SAVE00
	ST R1, SAVE10
	ST R2, SAVE20	
	ST R3, SAVE30	; COUNTER
	ST R5, SAVE50
	ST R6, SAVE60
	ST R7, SAVE70


; NOW HAVE TO CHECK D1 BY GOING RIGHT,UP AND LEFT,DOWN AND KEEPING A CONUNTER

	AND R3, R3, #0
	ADD R3, R3, #1	; MAKE THE COUNTER ONE INITALLY BECAUSE OF THE FIRST MOVE
	LD R4, LAST_MVE

D1_UP
	ADD R4, R4, #-6 ; CHECK GOING UP,RIGHT FIRST
	LDR R0, R4, #0 ; GET THE PIECE UP,RIGHT OF THE CURRENT MOVE IN R0

	LDI R2, TURN_MEM
	ADD R1, R2, #-1    
	BRZ D1_PLAYER1_CHECK_UP
	BR D1_PLAYER2_CHECK_UP	

D1_PLAYER1_CHECK_UP
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ D1_UP_MATCH
	LD R4, LAST_MVE
	BR D1_DOWN

D1_PLAYER2_CHECK_UP
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ D1_UP_MATCH
	LD R4, LAST_MVE
	BR D1_DOWN

D1_UP_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR D1_UP ; CHECK RIGHT,UP AGAIN

D1_DOWN 
	ADD R4, R4, #6  ; CHECK DOWN,LEFT NOW ONCE THERE IS NO MORE MATCH
	LDR R0, R4, #0 	; GET THE PIECE DOWN,LEFT OF THE CURRENT MOVE IN R0
	
	LDI R2, TURN_MEM
	ADD R1, R2, #-1    
	BRZ D1_PLAYER1_CHECK_DOWN
	BR D1_PLAYER2_CHECK_DOWN

D1_PLAYER1_CHECK_DOWN
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ D1_DOWN_MATCH
	BR CHECK_D1_WINNER

D1_PLAYER2_CHECK_DOWN
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ D1_DOWN_MATCH
	BR CHECK_D1_WINNER

D1_DOWN_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR D1_DOWN ; CHECK RIGHT AGAIN

CHECK_D1_WINNER
	ADD R3, R3, #-4
	BRZP D1_WIN
	BR D1_LOSE

D1_LOSE	
	AND R4, R4, #0	
	BR D1_DONE

D1_WIN 
	AND R4, R4, #0
	ADD R4, R4, #1
	
D1_DONE
	LD R0, SAVE00
	LD R1, SAVE10
	LD R2, SAVE20
	LD R3, SAVE30
	LD R5, SAVE50
	LD R6, SAVE60
	LD R7, SAVE70	

	RET

TURN_MEM .FILL x30F5
SAVE00 .BLKW 1
SAVE10 .BLKW 1
SAVE20 .BLKW 1
SAVE30 .BLKW 1
SAVE40 .BLKW 1
SAVE50 .BLKW 1
SAVE60 .BLKW 1
SAVE70 .BLKW 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D2						;
;	description:	2nd diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D2	

	ST R0, SAVE00
	ST R1, SAVE10
	ST R2, SAVE20	
	ST R3, SAVE30	; COUNTER
	ST R5, SAVE50
	ST R6, SAVE60
	ST R7, SAVE70


; NOW HAVE TO CHECK D2 BY GOING LEFT,UP AND RIGHT,DOWN AND KEEPING A CONUNTER

	AND R3, R3, #0
	ADD R3, R3, #1	; MAKE THE COUNTER ONE INITALLY BECAUSE OF THE FIRST MOVE
	LD R4, LAST_MVE

D2_UP
	ADD R4, R4, #-8 ; CHECK GOING UP,LEFT FIRST
	LDR R0, R4, #0 ; GET THE PIECE UP,LEFT OF THE CURRENT MOVE IN R0

	LDI R2, TURN_MEM
	ADD R1, R2, #-1    
	BRZ D2_PLAYER1_CHECK_UP
	BR D2_PLAYER2_CHECK_UP	

D2_PLAYER1_CHECK_UP
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ D2_UP_MATCH
	LD R4, LAST_MVE
	BR D2_DOWN

D2_PLAYER2_CHECK_UP
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ D2_UP_MATCH
	LD R4, LAST_MVE
	BR D2_DOWN

D2_UP_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR D2_UP ; CHECK LEFT,UP AGAIN

D2_DOWN 
	ADD R4, R4, #8  ; CHECK DOWN,LEFT NOW ONCE THERE IS NO MORE MATCH
	LDR R0, R4, #0 	; GET THE PIECE DOWN,LEFT OF THE CURRENT MOVE IN R0
	
	LDI R2, TURN_MEM
	ADD R1, R2, #-1    
	BRZ D2_PLAYER1_CHECK_DOWN
	BR D2_PLAYER2_CHECK_DOWN

D2_PLAYER1_CHECK_DOWN
	LD R1, ASCII_P1O
	ADD R2, R0, R1 
	BRZ D2_DOWN_MATCH
	BR CHECK_D2_WINNER

D2_PLAYER2_CHECK_DOWN
	LD R1, ASCII_P2X
	ADD R2, R0, R1 
	BRZ D2_DOWN_MATCH
	BR CHECK_D2_WINNER

D2_DOWN_MATCH
	ADD R3, R3, #1 ; INCREASE COUNTER IF THERE IS A MATCH
	BR D2_DOWN ; CHECK RIGHT AGAIN

CHECK_D2_WINNER
	ADD R3, R3, #-4
	BRZP D2_WIN
	BR D2_LOSE

D2_LOSE	
	AND R4, R4, #0	
	BR D2_DONE

D2_WIN 
	AND R4, R4, #0
	ADD R4, R4, #1
	
D2_DONE
	LD R0, SAVE00
	LD R1, SAVE10
	LD R2, SAVE20
	LD R3, SAVE30
	LD R5, SAVE50
	LD R6, SAVE60
	LD R7, SAVE70	

	
	RET


.END