# 5-Stage Pipelined Processor  

## Overview  
This project implements a **5-stage pipelined processor** using **VHDL**. It follows a **Harvard architecture** with separate **instruction and data memory** and supports a **custom RISC-like ISA**. The processor handles **arithmetic, logical, memory, and control instructions**, along with **exception handling** and **pipeline hazard resolution**.  

## Features  
- **5-stage pipeline:** Fetch, Decode, Execute, Memory, Write-back  
- **Harvard Architecture:** Separate **instruction and data memory**  
- **RISC-like ISA:** Supports general-purpose and special-purpose registers  
- **Pipeline Hazard Handling:** Data forwarding, static branch prediction  
- **Exception Handling:** Stack underflow and invalid memory access  
- **FPGA Implementation:** Designed for **DE1-SoC FPGA board**  

## Architecture  
- **Registers:** 8 general-purpose, PC, SP, EPC, CCR  
- **ALU:** Supports addition, subtraction, logical operations  
- **Memory:** 4Kx16 Instruction & Data memory  
- **Control Unit:** Implements instruction decoding and hazard resolution  

## Implementation  
- **VHDL Design:** Each component implemented separately and integrated  
- **Assembler:** Converts assembly instructions into machine code  
- **Simulation:** Test programs loaded into memory and executed  


## Contributors  
Developed as part of Cairo University’s **Computer Architecture** course.  
