import re

def asm_to_mem(asm_file, mem_file):
    # Instruction and register mappings
    opcodes = {
        'NOP': '00000', 'HLT': '00001', 'SETC': '00010', 'NOT': '00011',
        'INC': '00100', 'OUT': '00101', 'IN': '00110', 'MOV': '00111',
        'ADD': '01000', 'SUB': '01001', 'AND': '01010', 'IADD': '01011',
        'PUSH': '01100', 'POP': '01101', 'LDM': '01110', 'LDD': '01111',
        'STD': '10000', 'JZ': '10001', 'JN': '10010', 'JC': '10011',
        'JMP': '10100', 'CALL': '10101', 'RET': '10110', 'INT': '10111',
        'RTI': '11000'
    }

    registers = {
        f'R{i}': f'{i:03b}' for i in range(8)
    }

    with open(asm_file, 'r') as asm, open(mem_file, 'w') as mem:
        lines_written = 0  # Counter to keep track of how many lines we have written

        for line in asm:
            line = line.strip()
            if not line or line.startswith('#'):  # Skip empty lines or comments
                continue

            

            if re.match(r'^[0-9A-Fa-f]+$', line):  # Check if the line is a standalone number
                number = int(line, 16)  # Treat the number as hexadecimal
                mem.write(f"{number:016b}\n")  # Write it as a 16-bit binary number
                lines_written += 1
                continue

            parts = re.split(r'[ ,()]+', line)
            instr = parts[0]

            if instr not in opcodes:
                raise ValueError(f"Unknown instruction: {instr}")

            opcode = opcodes[instr]
            binary_instr = opcode
            rsrc1 = rsrc2 = rdst = '000'
            index_bit = imm_bit = '0'
            #format opcode only
            if instr == 'NOP' or instr == 'HLT' or instr == 'SETC' or instr == 'RET' or instr == 'RTI':
                binary_instr += '0' * 11  # Fill remaining bits
                mem.write(binary_instr + '\n')
                lines_written += 1
                continue

            elif instr == 'INT':
                index_bit = parts[1]
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                lines_written += 1
                continue
            #format opcode Rsrc1
            elif instr in ['OUT' , 'PUSH','JZ', 'JN', 'JC', 'JMP', 'CALL']:
                rsrc1 = registers.get(parts[1], '000')
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                lines_written += 1
                continue

            #format opcode Rdst
            elif instr in ['IN', 'POP']:
                rdst = registers.get(parts[1], '000')
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                lines_written += 1
                continue

            #format opcode Rdst,Rsrc1
            elif instr in ['MOV', 'NOT', 'INC']:
                rdst = registers.get(parts[1], '000')
                rsrc1 = registers.get(parts[2], '000')
                
                binary_instr += rsrc1 + rsrc2 + rdst + '00'
                mem.write(binary_instr + '\n')
                lines_written += 1
                continue
            #format opcode Rdst , Rsrc1 , Rsrc2
            elif instr in ['ADD', 'SUB', 'AND']:
                rdst = registers.get(parts[1], '000')
                rsrc1 = registers.get(parts[2], '000')
                rsrc2 = registers.get(parts[3], '000')
                imm_bit = '0'
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                lines_written += 1
                continue
            #format opcode Rdst , Rsrc1 , IMM
            elif instr == 'IADD':
                rdst = registers.get(parts[1], '000')
                rsrc1 = registers.get(parts[2], '000')
                imm_bit = '1'
                imm_value = int(parts[3], 16)
                binary_instr += rsrc1 + '000' + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                mem.write(f"{imm_value:016b}" + '\n')
                lines_written += 2  # Because we write two lines here
                continue

            #format opcode Rdst IMM
            elif instr == 'LDM':
                rdst = registers.get(parts[1], '000')
                imm_bit = '1'
                imm_value = int(parts[2], 16)
                binary_instr += '000' + '000' + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                mem.write(f"{imm_value:016b}" + '\n')
                lines_written += 2  # Because we write two lines here
                continue
            #format opcode 
            elif instr in ['LDD', 'STD']:
                if instr == 'LDD':
                    rdst = registers.get(parts[1], '000')
                    rsrc1 = registers.get(parts[3], '000')
                    rsrc2 = '000'
                else:
                    rdst = '000'
                    rsrc1 = registers.get(parts[1], '000')
                    rsrc2 = registers.get(parts[3], '000')
                imm_bit = '1'
                offset = int(parts[2], 16)
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                mem.write(binary_instr + '\n')
                mem.write(f"{offset:016b}" + '\n')
                lines_written += 2  # Because we write two lines here
                continue

            else:
                raise ValueError(f"Instruction not yet supported: {instr}")

        # Fill remaining memory with zeros
        total_lines = 2**12 
        remaining_lines = total_lines - lines_written
        for _ in range(remaining_lines):
            mem.write('0' * 16 + '\n')  # Write 16-bit zeros

# Example usage:
asm_to_mem('program.asm', 'testx.mem')
