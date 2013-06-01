;Rafael A Pol Abellas
;802105568
;This program is used for multiplying two signed numbers from -32768 to 32767
;To introduce data to the algorithm change register contents of R7 and R8 (line 16 and 17)
;The result will be separated in two register. The most significant word will be 
;located at register R14 and the least significant word at register R15
#include "msp430.h"
;--------------------------------------------------------------
		ORG	0F800h			; Program Start
;--------------------------------------------------------------
RESET		mov.w	#0280h,SP		; Initialize stackpointer
StopWDT 	mov.w	#WDTPW+WDTHOLD,&WDTCTL	; StopWDT
		mov.w	#0,R4			; "boolean" (use for checking the number of negatives)
		mov.w	#0,R14			; Result MSW
		mov.w	#0,R15			; Result LSW
		mov.w	#0,R6			; use for comparing
		mov.w	#0,R8			; use only if 2xN generates carry and needs more than one register
		mov.w	#-32653,R7		; M
		mov.w	#42,R9			; N   (M x N)
		call	#Helper			; Helper method for negatives
Start		cmp.w	R6,R7			; checking if M=0
		jz	Finish			; Finish if M=0
		bit.b	#1,R7			; Testing if M is odd or even
		jz	Par			; if even jump
		add.w	R9,R15			; if odd Result= Result + N
		addc.w	R8,R14			; (if neccesary) add the carry to the MSW and add the contents of R8 to the MSW 
Par		clrc				; make sure that the rrc roll zeros
		rrc	R7			; M/2
		rla	R9			; N*2
		rlc	R8			; if Nx2 generates carry the result is carried on to R8 
		jmp	Start			; Continue Loop
		
Finish		cmp	#1,R4			; Loop finised, if there was one negative invert 
		jnz	Result			; else finish
		inv	R15			; Result needs to be negative
		inv	R14			; invert result
		add.w	#1,R15			; 2's complement of R15
		addc.w	#0,R14			; continue the carry to R14
Result		mov.w	#0,R10			; Finish!!
Here		jmp	Here
;--------------------------------------------------------------
;		Helper Method
;--------------------------------------------------------------
Helper		bit.w	#1000000000000000b,R7	; Checking sign of R7
		jz	Check2			; if negative Z=0 invert,else return
		inv	R7			
		add.w	#1,R7			; 2's complement of R7
		add.w	#1,R4			; Counter for negatives
Check2		bit.w	#1000000000000000b,R9	; Checking sign of R9
		jz	Return			; if negative Z=0280h invert,else return
		inv	R9			
		add.w	#1,R9			; 2's complement of R9
		add.w	#1,R4			; Counter for negatives
Return		ret
;---------------------------------------------------------------
;	Interrrupt Vectors
;---------------------------------------------------------------
		ORG	0FFFEh			; MSP430 Reset Vector
		DW	RESET			;
		END