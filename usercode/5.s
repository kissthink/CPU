		LI R0 0xBF
		LI R1 0x8
		SLLV R1 R0  			; R0 = 0xBF00
LOOP:
		NOP
		LW R0 R1 0x0 			; R1 = input_number
		SLTI R1 0x31			; T = R1 < char(1)
		NOP
		BTEQZ BIGEN				; T=0 ==> BIGEN.  big enough
		NOP
		B END
		NOP
BIGEN:
		NOP
		SLTI R1 0x40			; T = R1 < (char(9) + 1)
		NOP
		BTEQZ END				; T=0 ==> END. too big.
		NOP

		ADDIU R1 0xD0			; R1 = R1 - 0x30 = real_number
		LI R4 0x0A				; R4 = return
		SW R0 R4 0x0			; Print a return
		LI R5 0x0				; R5 = 0               R5 : current row index.  1-->2-->N-->2-->1
ROW1:
		NOP
		ADDIU R5 0x1			; R5 = R5 + 1
		NOP
		SUBU R1 R5 R6			; R6 = R1 - R5         R6 : number of blankspace before @
		ADDU R5 R5 R2			; R2 = R5 + R5    R7 --> R2
		ADDIU R2 0xFF			; R2 = R2 - 1          R2 : number of @ in this row
COL1_1:
		NOP
		CMPI R6 0x0	
		BTEQZ COL1_2
		NOP
		LI R4 0x20				; R4 = blankspace
		SW R0 R4 0x0			; Print a blankspace
		ADDIU R6 0xFF			; R6 = R6 - 1
		NOP
		BNEZ R6 COL1_1
COL1_2:
		NOP
		LI R4 0x40				; R4 = @
		SW R0 R4 0x0			; Print an @
		ADDIU R2 0xFF			; R2 = R2 - 1
		NOP
		BNEZ R2 COL1_2
		NOP
		LI R4 0x0A				; R4 = return
		SW R0 R4 0x0			; Print a return
		
		CMP R5 R1
		NOP
		BTNEZ ROW1

ROW2:
		NOP
		ADDIU R5 0xFF			; R5 = R5 - 1
		NOP
		CMPI R5 0x0	
		BTEQZ LOOP
		NOP
		SUBU R1 R5 R6			; R6 = R1 - R5
		ADDU R5 R5 R2			; R2 = R5 + R5
		ADDIU R2 0xFF			; R2 = R2 - 1
COL2_1:
		NOP
		LI R4 0x20
		SW R0 R4 0x0			; Print a blankspace
		ADDIU R6 0xFF
		NOP
		BNEZ R6 COL2_1

COL2_2:
		NOP
		LI R4 0x40
		SW R0 R4 0x0			; Print an @
		ADDIU R2 0xFF
		NOP
		BNEZ R2 COL2_2
		NOP
		LI R4 0x0A
		SW R0 R4 0x0			; Print a return
		
		NOP
		B ROW2
END:	
		NOP
		NOP
		JR R7