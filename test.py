import argparse
import re
from enum import Enum

def decimal_to_binary(n, size):
    if isinstance(n, str):
        n = int(n)
    if n < 0:
        n = (1 << size) + n
    res = bin(n)[2:]
    assert len(res) <= size
    return res.zfill(size)

def hex_to_binary(n, size=16):
    if isinstance(n, str):
        n = int(n, 16)
    if n < 0:
        n = (1 << size) + n
    res = bin(n)[2:]
    assert len(res) <= size
    return res.zfill(size)

class OperandType(Enum):
    DEST = "dest"
    SRC1 = "src1"
    SRC2 = "src2"
    IMMEDIATE = "immediate"

class Instruction:
    def __init__(self, name, opcode, num_operands, operand_types, regex):
        self.name = name
        self.opcode = opcode
        self.num_operands = num_operands
        self.operand_types = [tuple(OperandType(op) for op in ops_tuple) for ops_tuple in operand_types]
        self.regex = re.compile(regex)

ISA = {
    "RET": Instruction("RET", "10101", 0, [], ""),
    "RTI": Instruction("RTI", "00110", 0, [], ""),
    "HLT": Instruction("HLT", "00001", 0, [], ""),
    "OUT": Instruction("OUT", "00011", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "PUSH": Instruction("PUSH", "01001", 1, [(OperandType.SRC2,)], r" *R([0-7])"),
    "JZ": Instruction("JZ", "10000", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "JC": Instruction("JC", "10010", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "JMP": Instruction("JMP", "10011", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "CALL": Instruction("CALL", "10100", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "IN": Instruction("IN", "00100", 1, [(OperandType.DEST,)], r" *R([0-7])"),
    "POP": Instruction("POP", "01010", 1, [(OperandType.DEST,)], r" *R([0-7])"),
    "INC": Instruction("INC", "11001", 1, [(OperandType.DEST,)], r" *R([0-7])"),
    "LDM": Instruction("LDM", "01011", 2, [(OperandType.DEST,), (OperandType.IMMEDIATE,)], r" *R([0-7]) *, *([0-9A-F][0-9A-F]*)"),
    "LDD": Instruction("LDD", "01100", 2, [(OperandType.DEST,), (OperandType.IMMEDIATE,), (OperandType.SRC1,)], r" *R([0-7]) *, *([0-9A-F]+) *\( *R([0-7]) *\)"),
    "STD": Instruction("STD", "01101", 2, [(OperandType.SRC2,), (OperandType.IMMEDIATE,), (OperandType.SRC1,)], r" *R([0-7]) *, *([0-9A-F]+) *\( *R([0-7]) *\)"),
    "IADD": Instruction("IADD", "01000", 2, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.IMMEDIATE,)], r" *R([0-7]) *, *R([0-7]) *, *([0-9A-F][0-9A-F]*)"),
    "ADD": Instruction("ADD", "11011", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-7]) *, *R([0-7]) *, *R([0-7])"),
    "NOP": Instruction("NOP", "00000", 0, [], ""),
    "INT": Instruction("INT", "00101", 1, [(OperandType.IMMEDIATE,)], r" *([0-9A-F][0-9A-F]*)"),
    "SUB": Instruction("SUB", "11100", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-7]) *, *R([0-7]) *, *R([0-7])"),
    "MOV": Instruction("MOV", "11010", 2, [(OperandType.DEST,), (OperandType.SRC1,)], r" *R([0-7]) *, *R([0-7])"),
    "NOT": Instruction("NOT", "11000", 1, [(OperandType.DEST,)], r" *R([0-7])"),
    "SETC": Instruction("SETC", "00010", 0, [], ""),
    ".ORG":     Instruction(".ORG",     "", 0, [(OperandType.IMMEDIATE,)], r" *([0-9A-F][0-9A-F]?[0-9A-F]?[0-9A-F]?)")
}

def transpile(lines):
    transpiled = []
    org = 0
    is_value = re.compile(r"^ *([0-9][0-9A-F]*)(?: *)?$")

    for i, line in enumerate(lines):
        idx = line.find("#")
        if idx != -1:
            line = line[:idx]
        line = line.upper().strip()
        if not line:
            continue

        if is_value.match(line):
            value = int(line, 16)
            transpiled.append((org, hex_to_binary(value, 16)))
            org += 1
            continue

        name = line.split(" ")[0]
        if name not in ISA:
            raise ValueError(f"Error at line {i + 1}: Instruction {name} not found")

        if ISA[name].name == ".ORG":
            org = int(ISA[name].regex.findall(line)[0], 16)
            continue

        tr_line = decimal_to_binary(ISA[name].num_operands, 2) + ISA[name].opcode
        dest, src1, src2 = "000", "000", "000"
        imm, isImm = "0" * 16, "0"

        if ISA[name].regex:
            matches = ISA[name].regex.findall(line)
            if not matches:
                raise ValueError(f"Error at line {i + 1}: Invalid operand format for {name}")
            matches = matches[0]

            for j, match in enumerate(matches):
                for opType in ISA[name].operand_types[j]:
                    if opType == OperandType.DEST:
                        dest = decimal_to_binary(match, 3)
                    elif opType == OperandType.SRC1:
                        src1 = decimal_to_binary(match, 3)
                    elif opType == OperandType.SRC2:
                        src2 = decimal_to_binary(match, 3)
                    else:
                        isImm = "1"
                        imm = hex_to_binary(match, 16)

        tr_line += dest + src1 + src2 + isImm
        transpiled.append((org, tr_line))
        org += 1

        if isImm == "1":
            transpiled.append((org, imm))
            org += 1

    return transpiled

def parse_transpiled(transpiled):
    output = []
    code_lines = ["{:0>4}: {:0>16}\n".format(i, "0") for i in range(4096)]
    for address, line in transpiled:
        code_lines[address] = "{:0>4}: {}\n".format(address, line)
    output.extend(code_lines)
    return output

def process_file(file_path, output_path):
    with open(file_path, "r") as file:
        lines = file.readlines()
    transpiled = transpile(lines)
    output = parse_transpiled(transpiled)
    with open(output_path, "w") as f:
        f.writelines(output)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", "-F", dest="file_path", default="./asm_example.asm", help="Path to the file to process")
    parser.add_argument("--output", "-O", dest="output_file", default="./program.mem", help="Output path")
    args = parser.parse_args()
    process_file(args.file_path, args.output_file)

if __name__ == "__main__":
    main()
