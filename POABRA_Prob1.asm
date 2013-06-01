;Rafael A Pol Abellas
;802105568
;This program converts decimal numbers in the range of 0 to 16 digits to hexadecimal.
;For this problem the data is introduced using BCD encoding and converted 
;to hexadecimal. To introduce data in the algorithm, starting with the most significant
;word, change the src of the move operation (MyDATA1), and so on until MyDATA4. (Starts at line 78)
;Example:
;	Decimal to Convert:24302453198
;	MyDATA1	mov	#0000h,&0200h		first 4 digits 
;	MyDATA2	mov	#0243h,&0202h		digits 5-8 
;	MyDATA3	mov	#0245h,&0204h		digits 9-12
;	MyDATA4	mov	#3198h,&0206h		last 4 digits
;
;The result will be displayed startin with the most significant word in R9 to R12
;with the least significant word.
#include	"msp430.h"
Extract_Left_Nibble	MACRO	dato,extractor
	mov #0,extractor	; initialize extractor
	rla dato		; b15 to carry
	rlc extractor		; b15 least significant bit
	rla dato		; b14 to carry
	rlc extractor		; b14 lsb (b15-b14)
	rla dato		; b13 to carry
	rlc extractor		; b13 lsb (b15-b14-b13)
	rla dato		; b12 to carry
	rlc extractor		; b12 lsb (b15-b14-b13-b12)
	ENDM
	
Mult_by_ten	MACRO	dato
	mov.w	#0,R13		; initializing registers
	mov.w	#0,R14		; this register will save the multiplication (2x) of
	mov.w	#0,R15		; the second,third and fourth word for later reference
	rla	dato		; 2*Dato
	rlc	R11		; continue multiplication to the other registers
	rlc	R10
	rlc	R9
	mov.w	R11,R13		; saves the multiplication of the other registers (x2)
	mov.w	R10,R14
	mov.w	R9,R15
	push	dato		; store 2*Dato
	rla	dato		; 4*Dato
	rlc	R11		; continue multiplication to the other registers
	rlc	R10
	rlc	R9
	rla	dato		; 8*Dato
	rlc	R11		; continue multiplication to the other registers
	rlc	R10
	rlc	R9
	add	@SP+,dato	; 10*Dato and restore TOS
	addc	#0,R11		; add the carry of the LSW to the second word
	add	R13,R11		; completes the multiplication of the second register (x10)
	addc	#0,R10		; add the carry of the second word to the third register	; This code make sure that the multiplication gets carry
	add	R14,R10		; completes the multiplication of the third register (x10)	; on to the other register
	addc	#0,R9		; add the carry of the third register to the MSW
	add	R15,R9		; completes the multiplication of the MSW (x10)
	ENDM

Work	MACRO	dato
	Mult_by_ten	R12		; P=P*10	
	Extract_Left_Nibble dato,R6	; Extract N3
	add	R6,R12			; 
	addc	#0,R11			; if there is a carry update the other register
	addc	#0,R10
	addc	#0,R9
	Mult_by_ten	R12		; P*A = N3*10
	Extract_Left_Nibble	dato,R6	; Extract N2
	add	R6,R12			; update conversion N3*10+N2
	addc	#0,R11			; if there is a carry update the other register
	addc	#0,R10
	addc	#0,R9
	Mult_by_ten	R12		; P=(N3*A+N2)*10
	Extract_Left_Nibble	dato,R6	; Extract N1
	add	R6,R12			; update conversion (N3*A+N2)*A+N1
	addc	#0,R11			; if there is a carry update the other register
	addc	#0,R10
	addc	#0,R9
	Mult_by_ten	R12		; P=P*A
	Extract_Left_Nibble	dato,R6	; Extract N0
	add	R6,R12			; update and finish conversion ((N3*A+N2)*A+N1)*A+N0
	addc	#0,R11			; if there is a carry update the other register
	addc	#0,R10	
	addc	#0,R9
	ENDM
	
;-------------------------------------------------------------------------------
		ORG	0xF800	; Program Start
;-------------------------------------------------------------------------------
RESET	mov	#280h,SP		; init SP
StopWDT	mov	#WDTPW+WDTHOLD,&WDTCTL	; stop WDT
MyDATA1	mov	#0000h,&0200h		; first 4 digits 
MyDATA2	mov	#0010h,&0202h		; digits 5-8 
MyDATA3	mov	#0000h,&0204h		; digits 9-12
MyDATA4	mov	#0568h,&0206h		; lasts digits 
	mov.w	#0,R11			; initializing resgisters
	mov.w	#0,R12			
	mov.w	#0,R13
	mov.w	#0,R10
	mov.w	#0,R15
	mov.w	#0,R9
	mov	&0200h,R4		
	Work	R4
	mov 	&0202h,R4
	Work	R4
	mov 	&0204h,R4
	Work	R4
	mov	&0206h,R4
	Work	R4
	jmp	$	; breakpoint
;-------------------------------------------------------------------------------
;	Interrupt Vectors
;-------------------------------------------------------------------------------
	ORG	0xFFFE			; MSP430 Reset Vector
	DW	RESET			; address label RESET
	END
