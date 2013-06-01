; Rafael Pol Abellas
; 802105568
; This program will make both LEDs flash simultaneously at aproximate 2Hz.
; At each push of the button in P1.3 the red LED frequency will increase
; in such a way that it toggles 2, 3, 4, and 5 times faster than the green LED. 
#include "msp430.h"
;-------------------------------------------------------------
		ORG	0F800h			; Program Start
;-------------------------------------------------------------
RESET		mov.w	#0280h,SP		; Initialize stackpointer
StopWDT 	mov.w	#WDTPW+WDTHOLD,&WDTCTL	; StopWDT
SetupP1 	bis.b	#11111111b,&P1DIR	; P1.0/P1.6 as output (All pins in output)
		bic.b	#01000001b,P1OUT	; both LEDs off
		bic.b	#00001000b,P1SEL	; default
		bic.b	#00001000b,P1IFG	; clear int. flag
		bic.b	#00001000b,&P1DIR	; P1.3 as input port
		bis.b	#00001000b,P1IE		; enable P1.3 int.
		mov	#0,R7			; Initialize Button Counter
		eint				; Enable Global Interrupt Flag
		mov.w	#0,R4			; Counter for the loops of the red LED
		mov.w	#0,R5			; Counter for the loops of the red LED
		mov.w	#25430,R6		; Loops calculate for 2Hz
Here		add	#1,R4			; Increment the counter of the red LED
		add	#1,R5			; Increment the counter of the green LED
		cmp	R6,R4			; Compare if the red loop reach the iterations 
		jz	TogRed			; if true toggle red LED
Red		cmp	#25430,R5		; Compare if the green loop reach the iterations
		jz	TogGreen		; if true toggle green LED
Green		jmp	Here			; Infinite Loop
TogRed		xor.b	#1,P1OUT		; Toogle red LED
		mov	#0,R4			; Restart Counter
		jmp	Red			; jump to loop
TogGreen	xor.b	#01000000b,P1OUT	; Toogle green LED
		mov.w	#0,R5			; Restart Counter
		jmp	Here			; jump to loop
;-------------------------------------------------------------
;		P1.3 Interrup Service Routine
;-------------------------------------------------------------
PBISR		bic.b	#00001000b,P1IFG	; clear int. flag
		bic.b	#01000001b,P1OUT	; Turn off both LEDs
		mov.w	#0,R4			; Restart Counter for both LEDS
		mov.w	#0,R5			; 
		add.w	#1,R7			; Add one to the counter of button presses
		cmp	#1,R7			; If one presses
		jz	Hz2			; jump to twice the hertz 2*Hertz 
		cmp	#2,R7			; If two presses
		jz	Hz3			; jump to triple the hertz 3*Herts
		cmp	#3,R7			; If three presses
		jz	Hz4			; jump to quadruple the hertz 4*Hertz
		cmp	#4,R7			; If fourth presses
		jz	Hz5			; jump to quintuple the hertz 5*Hertz
		mov.w	#25430,R6		; else restart the red LED herts with
		mov.w	#0,R7			; the original hertz 
		jmp	Finish			; end iterrupt
Hz2		mov.w	#12800,R6		; Save 2*Hertz in R6
		jmp	Finish
Hz3		mov.w	#8533,R6		; Save 3*Hertz in R6
		jmp	Finish
Hz4		mov.w	#6400,R6		; Save 4*Hertz in R6
		jmp	Finish
Hz5		mov.w	#5120,R6		; Save 5*Hertz in R6
Finish		reti 				; return from ISR
;--------------------------------------------------
;	Interrrupt Vectors
;-------------------------------------------------
		ORG	0FFFEh		; MSP430 Reset Vector
		DW	RESET		;
		ORG	0FFE4h		; interrupt vector 2
		DW	PBISR		; address of label PBISR
		END