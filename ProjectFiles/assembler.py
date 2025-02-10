import re

def is_hex_number(value):
    """Check if the value is a hex number (with or without 0x prefix)"""
    # Remove any comments after #
    value = value.split('#')[0].strip()
    try:
        int(value, 16)
        return True
    except ValueError:
        return False

def convert_to_decimal(value):
    """Convert a string to decimal, assuming it is hexadecimal if it contains only hex characters."""
    # Remove any comments after #
    value = value.split('#')[0].strip()
    try:
        # Check if the value is hexadecimal (contains only hex digits)
        if all(c in "0123456789ABCDEFabcdef" for c in value):
            return int(value, 16)  # Treat as hexadecimal
        else:
            return int(value)  # Otherwise, treat as decimal
    except ValueError:
        raise ValueError(f"Invalid numeric value: {value}")

def assemble_instruction(line):
    # Remove comments from the line
    line = line.split('#')[0].strip()
    
    # Define instruction formats
    instruction_set = {
    "NOT": "11000",   # R-type
    "INC": "11001",   # R-type
    "MOV": "11010",   # R-type
    "ADD": "11011",   # R-type
    "SUB": "11100",   # R-type
    "AND": "11101",   # R-type
    "IADD": "01000",  # I-type
    "PUSH": "01001",  # I-type
    "POP": "01010",   # I-type
    "LDM": "01011",   # I-type
    "LDD": "01100",   # I-type
    "STD": "01101",   # I-type
    "JZ": "10000",    # J-type
    "JN": "10001",    # J-type
    "JC": "10010",    # J-type
    "JMP": "10011",   # J-type
    "CALL": "10100",  # J-type
    "RET": "10101",   # J-type
    "NOP": "00000",   # Special
    "HLT": "00001",   # Special
    "SETC": "00010",  # Special
    "OUT": "00011",   # Special
    "IN": "00100",    # Special
    "INT": "00101",   # Special
    "RTI": "00110",   # Special
    }


    # Extract instruction and operands
    tokens = [t for t in re.split(r'[ ,()]+', line.strip()) if t]
    if not tokens:  # Skip empty lines after removing comments
        return []
        
    instruction = tokens[0]
    operands = tokens[1:]

    print(f"Instruction: {instruction}, Operands: {operands}")

    if instruction not in instruction_set:
        raise ValueError(f"Unknown instruction: {instruction}")

    opcode = instruction_set[instruction]
    binary_line = opcode

    def parse_register(reg):
        if not reg.startswith('R') or not reg[1:].isdigit():
            raise ValueError(f"Invalid register format: {reg}")
        reg_num = int(reg[1:])
        if reg_num < 0 or reg_num > 7:
            raise ValueError(f"Register out of range: {reg}")
        return f"{reg_num:03b}"

    if instruction in ["NOP", "SETC", "RET", "RTI", "HLT", "INT"]:
        if instruction == "INT":
            if len(operands) != 1 or not operands[0].isdigit() or int(operands[0]) not in [0, 1]:
                raise ValueError("INT instruction requires a single operand of 0 or 1.")
            interrupt_bit = int(operands[0])
            binary_line += f"{'0' * 10}{interrupt_bit:01b}"  # Last bit represents interrupt index
            return [binary_line]

        
        binary_line += "00000000000"  # Fill don't care bits with zeros
        return [binary_line]  # No operands

    if instruction in ["MOV", "NOT", "INC", "IADD"]:
        binary_line += f"{parse_register(operands[1])}{'000'}{parse_register(operands[0])}{'00'}"
    elif instruction in ["AND", "ADD", "SUB"]:
        binary_line += f"{parse_register(operands[1])}{parse_register(operands[2])}{parse_register(operands[0])}{'00'}"
    elif instruction == "LDD":
        binary_line += f"{parse_register(operands[2])}{'000'}{parse_register(operands[0])}{'00'}"
        return [binary_line]
    elif instruction == "STD":
        binary_line += f"{parse_register(operands[2])}{parse_register(operands[0])}{'000'}{'00'}"
        return [binary_line]
    elif instruction == "LDM":
        binary_line += f"{'000000'}{parse_register(operands[0])}{'00'}"
        return [binary_line]
    elif instruction == "PUSH":
        binary_line += f"{parse_register(operands[0])}{'000000'}{'00'}"
    elif instruction == "POP":
        binary_line += f"{'000000'}{parse_register(operands[0])}{'00'}"
    elif instruction == "CALL":
        binary_line += f"{parse_register(operands[0])}{'000000'}{'00'}"
    elif instruction == "IN":
        binary_line += f"{'000000'}{parse_register(operands[0])}{'00'}"
    elif instruction == "OUT":
        binary_line += f"{parse_register(operands[0])}{'000000'}{'00'}"
    elif instruction in ["JZ", "JN", "JC", "JMP"]:
        binary_line += f"{parse_register(operands[0])}{'000000'}{'00'}"

    return [binary_line]

def assemble_file(input_file, output_file):
    max_memory_size = 4095  # Maximum memory size (4096 locations)
    current_address = 0
    memory = ["0000000000000000"] * (max_memory_size + 1)  # Initialize memory with NOPs

    with open(input_file, 'r') as infile:
        lines = infile.readlines()
        
        for i, line in enumerate(lines):
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue
                
            # Handle .ORG directive
            if line.startswith('.ORG'):
                org_value = line.split('.ORG')[1].strip().split('#')[0].strip()
                try:
                    current_address = convert_to_decimal(org_value)
                    print(f".ORG directive: Setting current address to {current_address} (0x{current_address:X})")
                except ValueError:
                    print(f"Error: Invalid address in .ORG directive on line {i+1}: {line}")
                continue

            # Check if the line is a raw hex number after an .ORG directive
            if is_hex_number(line):
                print(f"Ignoring raw hex number at line {i+1}: {line}")
                continue

            # Handle regular instructions
            try:
                tokens = [t for t in re.split(r'[ ,()]+', line.strip()) if t]
                binary_lines = assemble_instruction(line)

                # Write the main instruction
                instruction_binary = binary_lines[0]  # Instruction binary
                if current_address > max_memory_size:
                    raise ValueError("Memory overflow.")
                
                memory[current_address] = instruction_binary
                print(f"Writing instruction to address {current_address} (0x{current_address:X}): {instruction_binary}")
                current_address += 1

                # Handle immediate value if present
                if tokens[0] in ['LDD', 'STD']:
                    # Extract the immediate value
                    if len(tokens) > 0 :
                        immediate_value = convert_to_decimal(tokens[2])
                        immediate_binary = f"{immediate_value:016b}"
                        if current_address > max_memory_size:
                            raise ValueError("Memory overflow.")
                        memory[current_address] = immediate_binary
                        print(f"Writing immediate value to address {current_address} (0x{current_address:X}): {immediate_binary}")
                        current_address += 1
                elif tokens[0] == 'LDM':
                    # Extract the register to be loaded
                    if len(tokens) > 0 :
                        immediate_value = convert_to_decimal(tokens[2])
                        immediate_binary = f"{immediate_value:016b}"
                        if current_address > max_memory_size:
                            raise ValueError("Memory overflow.")
                        memory[current_address] = immediate_binary
                        print(f"Writing immediate value to address {current_address} (0x{current_address:X}): {immediate_binary}")
                        current_address += 1
                elif tokens[0] == 'IADD':
                    # Extract the register to be loaded
                    if len(tokens) > 0 :
                        immediate_value = convert_to_decimal(tokens[3])
                        immediate_binary = f"{immediate_value:016b}"
                        if current_address > max_memory_size:
                            raise ValueError("Memory overflow.")
                        memory[current_address] = immediate_binary
                        print(f"Writing immediate value to address {current_address} (0x{current_address:X}): {immediate_binary}")
                        current_address += 1

            except ValueError as e:
                print(f"Error at line {i+1}: {e}")
                print(f"Line content: {line}")

    # Write the final memory contents to the output file in the required .mem format
    with open(output_file, 'w') as outfile:
        outfile.write("// memory data file (do not edit the following line - required for mem load use)\n")
        outfile.write("// instance=/fetch_stage/IM_Instance/memory\n")
        outfile.write("// format=mti addressradix=h dataradix=b version=1.0 wordsperline=4\n")
        
        for i in range(0, max_memory_size + 1, 4):
            address = f"{i:x}".zfill(1)  # Convert address to hexadecimal
            data = " ".join(memory[i:i+4])  # Get the next 4 memory words
            outfile.write(f"  {address}: {data}\n")

# Example usage
assemble_file("testcase_cus.txt", "output_finaal.mem")
