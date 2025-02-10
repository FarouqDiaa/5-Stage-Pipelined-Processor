# all numbers are in hexadecimal
# numbers take the format [0-9][0-9A-F]*, i.e. 1, 50, 5FA, 0DEAD, 0BEEF, etc. but not DEAD or BEEF
# this is a commented line
# Your assembler should be indifferent to indentation
.ORG 0 #this means the the following line would be at address  0 , and this is the reset address
200
#you should ignore empty lines

.ORG 1  #this is the address of the empty stack exception handler
400

.ORG 2  #this is the address of the invalid memory address exception handler
600

# for those who are implementing the bonus (dynamic vector table):
.ORG 3  #this is the address of INT0
800

.ORG 4  #this is the address of INT1
0A00

# for those who are implementing the bonus (dynamic vector table):
# .ORG 3
# 100
# .ORG 100
# 800
# 0A00

# Empty Stack Exception Handler
.ORG 400
	PUSH R0
	LDM R0, 0DEAD
	OUT R0
	POP R0
	HLT

# Invalid Memory Address Exception Handler
.ORG 600
	PUSH R0
	LDM R0, 0C0DE
	OUT R0
	POP R0
	HLT

# INT0
.ORG 800
	PUSH R0
	LDM R0, 0CAFE
	OUT R0
	POP R0
	RTI

# INT1
.ORG 0A00
	PUSH R0
	LDM R0, 0BABE
	OUT R0
	POP R0
	RTI


# Main loop
.ORG 200
	IN R0
	PUSH R0
	POP R1
	IN R2
	STD R1,201(R2)
	LDD R3,201(R2)
	OUT R3
	LDM R3, 300
	CALL R3 # Function call
	OUT R1 # Display output
	LDM R1, 200 # Main loop address
	JMP R1 # Main loop jump

# Function
.ORG 300
	LDM R2, 30F # RET address
	LDM R3, 30A # Loop beginning address
	LDM R1, 0
	ADD R0, R0, R1 # R0 = R0 + 0
	JZ R2 # if (R0 == 0) return
	IADD R0, R0, 0FFFF # R0 = R0 - 1
	ADD R1, R1, R0
	INC R1
	IADD R0, R0, 0FFFF # R0 = R0 - 1
	JC R3 # if (R0 != -1) goto Loop beginning
	RET