; Rafael Pol Abellas
; 802105568
; This program will make the red LED flash for 0.30s. Changing the bits
; 5 and 4 of the BCSTL2 will alter the frequency of the MCLK. (f= 1MHz)
;		5  4 (bits) | Frequency
;		0  0        |    f
;		0  1	    |   f/2
;		1  0        |   f/4
;		1  1        |   f/8
#include "msp430.h"
;-------------------------------------------------------------
		ORG	0F800h			; Program Start
;-------------------------------------------------------------
RESET		mov.w	#0280h,SP		; Initialize stackpointer
StopWDT 	mov.w	#WDTPW+WDTHOLD,&WDTCTL	; StopWDT
FreqChange	bis.b	#00000000b,BCSCTL2
SetupP1 	bis.b	#11111111b,&P1DIR	; All pins as output
		bic.b	#01000000b,P1OUT
Main	 	xor.b	#1,&P1OUT		; Toggle P1.0
Wait		mov.w	#50000,R15		; Delay to R15
L1		dec.w	R15			; Decrement R15
		jnz	L1			; Delay over?
		jmp	Main			; Again
;--------------------------------------------------
;	Interrrupt Vectors
;-------------------------------------------------
		ORG	0FFFEh			;MSP430 Reset Vector
		DW	RESET			;
		END