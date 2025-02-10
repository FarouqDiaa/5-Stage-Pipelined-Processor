5
200
100
50
60
# NOP instruction
NOP

# HLT instruction
HLT

# SETC instruction
SETC

# NOT Rdst, Rsrc1
NOT R0, R1

# INC Rdst, Rsrc1
INC R2, R3

# OUT Rsrc1
OUT R4

# IN Rdst
IN R5

# MOV Rdst, Rsrc1
MOV R6, R7

# ADD Rdst, Rsrc1, Rsrc2
ADD R0, R1, R2

# SUB Rdst, Rsrc1, Rsrc2
SUB R3, R4, R5

# AND Rdst, Rsrc1, Rsrc2
AND R6, R7, R0

# IADD Rdst, Rsrc1, Imm
IADD R0, R1, 0xFF

# PUSH Rsrc1
PUSH R1

# POP Rdst
POP R2

# LDM Rdst, Imm
LDM R3, 0xABCD

# LDD Rdst, offset(Rsrc1)
LDD R4, 255(R2)

# STD Rsrc1, offset(Rsrc2)
STD R5, 3(R3)

# JZ Rsrc1
JZ R0

# JN Rsrc1
JN R1

# JC Rsrc1
JC R2

# JMP Rsrc1
JMP R3

# CALL Rsrc1
CALL R4

# RET instruction
RET

# INT index
INT 0
INT 1

# RTI instruction
RTI
