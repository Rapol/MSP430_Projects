; Rafael Pol Abellas
; 802105568
; This program will make both LEDs alternate for 0.5s.
#include "msp430.h"

Delay	MACRO	dato
	LOCAL L1
	mov.w	dato,R15	; Initialize Delay
L1:	dec	R15		; Decremetn Delay
	jnz	L1		; Delay over?
	ENDM			; If over End
;-------------------------------------------------------------
		ORG	0F800h			; Program Start
;-------------------------------------------------------------
RESET		mov.w	#0280h,SP		; Initialize stackpointer
StopWDT 	mov.w	#WDTPW+WDTHOLD,&WDTCTL	; StopWDT
SetupP1 	bis.b	#01100001b,&P1DIR	; P1.0/P1.6/P1.5 as output
		bic.b	#01000001b,&P1OUT	; Both LEDs off
MainLoop 	xor.b	#00100001b,&P1OUT	; Toggle P1.0/P1.5
		Delay	#41665			
		Delay	#41665
		xor.b	#01100001b,&P1OUT	; P1.0/P1.5 off, P1.6 On
		Delay	#41665
		Delay	#41665
		xor.b	#01000000b,&P1OUT	; P1.6 off
		jmp	MainLoop		; Again
;--------------------------------------------------
;	Interrrupt Vectors
;--------------------------------------------------
		ORG	0FFFEh		;MSP430 Reset Vector
		DW	RESET		;
		END