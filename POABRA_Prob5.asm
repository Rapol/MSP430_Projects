; Rafael Pol Abellas
; 802105568
; This program will use the memory RAM as display. The display will show operations of 
; two numbers. Operations start at address 0220h and consists of sum, difference,
; multiplication, divition, and residue. The IAR reads the memory in ASCII convention,
; the program converts the ASCII code to HEX and perform the desire operations, at last
; it will convert the HEX to ASCII for the display to read it. 
;
; To introduce data change the first directive ( in line 200) with the desire numbers (M and N). The first 
; number (M) needs to have a blank space bejore and after, the second number (N) needs to have 
; a blank space before and the colon after. Place Breakpoint at 272, run the program to the breakpoint for result.

; Example:
;	DB 	'For  M= 3 and N= 0:',0,0
; Example:
;	DB 	'For  M= 123 and N= 234:',0,0
; Example:
;	DB 	'For  M= 23 and N= 23:',0,0
#include "msp430.h"
Division MACRO	 M, N
	LOCAL	 Loop, Finish, DivBy0
	mov.w	 M,R4	 ; Initialize R4 with M (Residuo)
	mov.w	 N,R5	 ; Initialize R5 with N
	mov.w	 #0,R6	 ; Initialize counter (Cociente) 
	cmp	N,R6	 ; Check if N=0
	jz	DivBy0   ; Divided by Zero
Loop:	cmp	 R5,R4	 ; if M >= N proceed
	jnc	 Finish	 ; If M<N jump
	sub.w	 R5,R4	 ; M <- M - N
	add.w	 #1,R6	 ; R6++ 
	jmp	 Loop	 ; Repeat Loop
DivBy0:	mov	#1,R10	 ; Boolean for dividing by zero
Finish:	ENDM

		
Hex_To_ASCII MACRO	H
	LOCAL	 Loop,Pops,SpaceR5, SpaceR6,SpaceR7,SpaceR8, Finish
	mov.w	#0,R8	 ; Conter for how many pops are needed
	mov.w	 H,R7	 ; Initialize R7 with Hex Num
;--------------------Converting to Decimal----------------
Loop:	Division R7, #0Ah ;
	push.w	 R4	 ; Save residue in stack , Saving the number in bcd each push! 
	add.w	 #1,R8	 ; Increase number of pops

	cmp.w	 #0,R6	 ; Check if coeficient is zero
	jz	 Pops	 ; if zero finish

	mov.w	 R6,R7	 ; Initialize R7 with coeficient continue dividing
	jmp	 Loop	 ; 

;--------------Converting the bcd number in ASCII-----------------

Pops:	sub.w	 #1,R8	 ; Decrement pops
	mov.w	 @SP+,R4 ; Pop first number
	add.w	 #30h,R4 ; Convert first number to ASCII
	
	cmp.w	 #0,R8	 ; If counter zero finish
	jz	 SpaceR5 ; Add spaces

	sub.w	#1,R8	 ; Decrement pops
	mov.w	@SP+,R5	 ; Pop second number
	add.w	#30h,R5  ; Convert second number to ASCII
	
	cmp.w	#0,R8	 ; Check counter
	jz	SpaceR6	 ; finish add spaces
	
	mov.w	@SP+,R6	 ; Pop third number
	add.w	#30h,R6	 ; Convert to ASCII
	
	sub.w	#1,R8	 ; Check counter
	jz	SpaceR7	 ; Add spaces if finish
	mov.w	@SP+,R7	 ; save number
	add.w	#30h,R7	 ; Convert it to ASCII
	
	sub.w	#1,R8	 ; Check counter
	jz	SpaceR8	 ; Add spaces if finish
	mov.w	@SP+,R8  ; move bcd in R8
	add.w	#30h,R8  ; Convert to ASCII
	jmp	Finish
	
SpaceR5: mov.b	#20h,R5		; Put space in R5
SpaceR6: mov.b  #20h,R6		; Put space in R6
SpaceR7: mov.b	#20h,R7		; Put space in R7
SpaceR8: mov.b	#20h,R8		; Put space in R8
Finish:  ENDM

Mult	MACRO	dato1, dato2
	LOCAL	Par, Finish, Loop
	mov.w	dato1,R10		; M
	mov.w	dato2,R11		; N   (M x N)
	mov.w	#0,R12			; Result
Loop:	tst	R10			; checking if M=0
	jz	Finish			; Finish if M=0
	bit.b	#1,R10			; Testing if M is odd or even
	jz	Par			; if even jump
	add.w	R11,R12			; if odd Result= Result + N
Par:	clrc				; make sure that the rrc roll zeros
	rrc	R10			; M/2
	rla	R11			; N*2
	jmp	Loop			; Continue Loop	
Finish:	ENDM

ASCII_To_Hex MACRO
	LOCAL	Loop, Continue, OneDigit, TwoDigit, ThreeDigit, OneDigit1, TwoDigit1, ThreeDigit1, Finish, L1
;---------------------------------
;Initializing M
;---------------------------------
	
	cmp.b	#020h,0209h	; Check if second number is white space
	jz	OneDigit	; if true jump
	cmp.b	#020h,020Ah	; Check if third number is white space
	jz	TwoDigit	; if true jump
	jmp	ThreeDigit	; is a three digit number
	
OneDigit: mov.b	0208h,R15	; The result is only one digit conversion is directly to HEX
	sub.b	#030h,R15	; Converting from ASCII to HEX
	jmp	Continue	; Continue to the other number
	
TwoDigit: mov.b	0209h,R4	; save the least significant digit
	mov.b	0208h,R5	; save the most significant digit
	sub.b	#030h,R4	; Converting to bcd
	sub.b	#030h,R5	; Converting to bcd
				; Converting to Decimal
	Mult	#0Ah,R5		; D1*10
	mov	R12,R5		
	add	R4,R5		;(D1*10)+D0 = #Hex
	mov	R5,R15		;The result is stored to R15 in hex (M)
	jmp	Continue
	
ThreeDigit: mov.b 020Ah,R4	; save the least significant digit
	mov.b	0209h,R5	; save the second digit 
	mov.b	0208h,R6	; save the most significant digit
	sub.b	#030h,R4	; Converting to BCD
	sub.b	#030h,R5
	sub.b	#030h,R6
				; Converting to Decimal
	Mult	#0Ah,R5		; D1*10
	mov	R12,R5		
	
	Mult	#064h,R6	; D2*100
	mov	R12,R6	
	
	add	R4,R5		; 10*D1 + D0
	add	R5,R6		; 100*D2 + 10*D1 + D0 = #Hex
	mov	R6,R15		; The result is stored to R15 in hex (M)
;---------------------------------
;Initializing N
;---------------------------------
Continue: mov.w	#020Fh,R7	; Checking the address of the second number
Try	cmp.b	#03Dh,0(R7)	; If contents of addres is equal to the ASCII code for equal(=)
	jz	L1		; Found the addresss
	inc	R7		; else inc 
	jmp	Try		; continue trying
L1:	inc	R7		; jump the space
	inc	R7		; R7 will have the addres of the first digit 
	mov	R7,R8		; save the address of the first number
	inc	R7		; R7 will have the addres of the second digit
	mov	R7,R9		; save the address of the second number
	inc 	R7		; R7 will have the addres of the second digit
	mov	R7,R10		; save the address of the third number
	cmp.b	#03Ah,0(R9)	; checking if the second number is the symbol (:)
	jz	OneDigit1	; if true jump
	cmp.b	#03Ah,0(R10)	; check if third number is the symbol (:)
	jz	TwoDigit1	; if true jump
	jmp	ThreeDigit1	; else is a number with three digits
	
OneDigit1: mov.b 0(R8),R14	; Only one digit save in R14
	sub.b	#030h,R14	; Convert to HEX
	jmp	Finish
	
TwoDigit1: mov.b 0(R9),R4	; save the least significant digit
	mov.b	0(R8),R5	; save the most significant digit
	sub.b	#030h,R4	; Convert to BCD
	sub.b	#030h,R5
				; Converting to Decimal
	Mult	#0Ah,R5		; D1*10
	mov	R12,R5
	add	R4,R5		;(D2*10)+D0 = #Hex
	mov	R5,R14		;The result is stored to R14 in hex (N)
	jmp	Finish
	
ThreeDigit1: mov.b 0(R10),R4	; save the least significant digit
	mov.b	0(R9),R5	; save the second digit
	mov.b	0(R8),R6	; save the least significant digit
	sub.b	#030h,R4	; Convert to BCD
	sub.b	#030h,R5
	sub.b	#030h,R6
				; Converting to Decimal
	Mult	#0Ah,R5		;D1*10
	mov	R12,R5			
	Mult	#064h,R6	;D2*100
	mov	R12,R6	
	add	R4,R5		;10*D1 + D0
	add	R5,R6		;100*D2 + 10*D1 + D0 = #Hex
	mov	R6,R14		;The result is stored to R14 in hex (N)
Finish:	ENDM
;--------------------------------------------------------------
		ORG	0200h			; Program Start
;--------------------------------------------------------------
		DB 	'For  M= 0 and N= 9:',0,0
		ORG	0220h
		DB	'M+N=    and M-N=    ',0,0
		DS8	10
		DB	'MxN=     ',0,0
		DS8	5
		DB	'M/N=    ',0,0
		DS8	6
		DB	'Residue=   ',0,0
		ORG 	0F800h
RESET		mov.w	#0280h,SP		; Initialize stackpointer
StopWDT 	mov.w	#WDTPW+WDTHOLD,&WDTCTL	; StopWDT
		bis.b	#11111111b,&P1DIR	; All pins in output
		ASCII_To_Hex			; Initialize R15 and R14
		mov.b	R15,R13			; Save M in R13 for doing operations
		add.w	R14,R13			; M + N result in R13
		Hex_To_ASCII	R13		; Convert Result in ASCII
		mov.b	R4,0224h		; Move ASCII to "display"
		mov.b	R5,0225h
		mov.b	R6,0226h
		mov.b	R15,R13			; Save M in R13 for doing operations
		sub.b	R14,R13			; M-N result in R13
		jnc	Negative		; If negative jump
		Hex_To_ASCII	R13		; Conver result to ASCII
		mov.b	R4,0230h		; move ASCII to "display"
		mov.b	R5,0231h
		mov.b	R6,0232h
Continue	mov.b	R15,R13			; Save M in R13 for doing operations
		Division R13,R14		; M/N
		cmp	#1,R10			; Safety Check if N=0 
		jz	Error			; Jump to Error Message
		mov.b	R4,R12			; save residue in R12
		mov.b	R6,R11			; save quotient in R11
		Hex_To_ASCII	R11		; Convert quotient
		mov.b	R4,0254h		; move ASCII to display
		mov.b	R5,0255h
		mov.b	R6,0256h
		Hex_To_ASCII	R12		; convert residue
		mov.b	R4,0268h
		mov.b	R5,0269h
		mov.b	R6,026Ah
Return		mov.b	R15,R13			; Save M in R13
		Mult	R15,R14			; MxN result in R12
		Hex_To_ASCII	R12		; Convert Result
		mov.b	R4,0244h		; Move ASCII to display
		mov.b	R5,0245h
		mov.b	R6,0246h
		mov.b	R7,0247h
		mov.b	R8,0248h
		jmp	Complete
Negative	mov.b	#02Dh,0230h		; Puts negative sign in display (-)
		inv.b	R13			; 2's complement
		inc	R13
		Hex_To_ASCII	R13		; Conver result to ASCII
		mov.b	R4,0231h		; move ASCII to "display"
		mov.b	R5,0232h
		mov.b	R6,0233h
		mov.b	R15,R13
		jmp	Continue
Error		mov.w	#07245h,0250h 		; Error message for dividing by zero 
		mov.w	#06F72h,0252h
		mov.w	#02072h,0254h
		mov.w	#06964h,0256h
		mov.w	#06976h,0258h
		mov.w	#06564h,025Ah
		mov.w	#02064h,025Ch
		mov.w	#07962h,025Eh
		mov.w	#07A20h,0260h
		mov.w	#07265h,0262h
		mov.w	#0006Fh,0264h
		mov.w	#00000h,0266h
		jmp	Return
Complete	nop
;--------------------------------------------------
;	Interrrupt Vectors
;--------------------------------------------------
		ORG	0FFFEh			; MSP430 Reset Vector
		DW	RESET			;
		END