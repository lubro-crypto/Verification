;------------------------------------------------------------------------------------------------------
; Design and Implementation of an AHB UART peripheral
; 1) Send text string: "TEST" to UART. 
; 2) Receive/ print characters from/ to a "computer" (your SystemVerilog testbench) through UART port.
;------------------------------------------------------------------------------------------------------


; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x00003FFC
        				DCD		Reset_Handler
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				
        				; External Interrupts
						        				
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY

;Write "TEST" to the UART
				LDR 	R1, =0x51000010 
				MOVS	R0, 0x00000005 
				STR		R0, [R1]

				LDR 	R1, =0x51000000
				MOVS	R0, #'T'
				STR		R0, [R1]

				LDR 	R1, =0x51000000
				MOVS	R0, #'E'
				STR		R0, [R1]

				LDR 	R1, =0x51000000
				MOVS	R0, #'S'
				STR		R0, [R1]
				
				LDR 	R1, =0x51000000
				MOVS	R0, #'T'
				STR		R0, [R1]

				LDR 	R1, =0x51000000
				MOVS	R0, #'F'
				STR		R0, [R1]


;wait until receive buffer is not empty

WAIT			LDR 	R1, =0x51000004
				LDR	R0, [R1]
				MOVS	R1, #01
				ANDS	R0,  R0,  R1
				CMP	R0,	#0x00
				BNE	WAIT		

;send received text to UART

				LDR 	R1, =0x51000000
				LDR 	R0, [R1]
				STR	R0, [R1]


				B		WAIT

				ENDP

				ALIGN 		4					 ; Align to a word boundary

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
   