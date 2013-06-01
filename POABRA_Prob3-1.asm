; Rafael Pol Abellas 
; 802105568
; This program configures the pins in port one as input or output. 
; While debugging, stop at line 15 to measure the voltage of the pins
; in low output. For high output, stop at line 16 and measure the desire
; pins.
#include <msp430.h>
;-------------------------------------------------------------------------------
            ORG     0F800h                  ; Program Reset
;-------------------------------------------------------------------------------
RESET       mov.w   #0280h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
	    bis.b   0FFh, P1DIR		    ; All pins configure to output
	    bic.b   0FFh, P1OUT		    ; All pins in low state
	    bis.b   0FFh, P1OUT  	    ; All pins in high state
Here	    jmp		Here
;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     0FFFEh                  ; MSP430 RESET Vector
            DW      RESET                   ;
            END
