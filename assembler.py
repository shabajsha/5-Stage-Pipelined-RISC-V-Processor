import re

OP_R      = 0b0110011
OP_I      = 0b0010011
OP_LOAD   = 0b0000011
OP_STORE  = 0b0100011
OP_BRANCH = 0b1100011


def reg_num(reg):
    return int(reg.replace("x", ""))


def mask(value, bits):
    return value & ((1 << bits) - 1)


def encode_r(funct7, rs2, rs1, funct3, rd, opcode):
    return (
        (funct7 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )


def encode_i(imm, rs1, funct3, rd, opcode):
    imm = mask(imm, 12)
    return (
        (imm << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (rd << 7) |
        opcode
    )


def encode_s(imm, rs2, rs1, funct3, opcode):
    imm = mask(imm, 12)
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0  = imm & 0x1F

    return (
        (imm_11_5 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (imm_4_0 << 7) |
        opcode
    )


def encode_b(imm, rs2, rs1, funct3, opcode):
    imm = mask(imm, 13)

    imm_12   = (imm >> 12) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1  = (imm >> 1) & 0xF
    imm_11   = (imm >> 11) & 0x1

    return (
        (imm_12 << 31) |
        (imm_10_5 << 25) |
        (rs2 << 20) |
        (rs1 << 15) |
        (funct3 << 12) |
        (imm_4_1 << 8) |
        (imm_11 << 7) |
        opcode
    )


def assemble(line):
    parts = re.split(r'[,\s()]+', line.strip())
    parts = [p for p in parts if p]
    inst = parts[0]

    if inst == "add":
        rd, rs1, rs2 = map(reg_num, parts[1:4])
        return encode_r(0b0000000, rs2, rs1, 0b000, rd, OP_R)

    if inst == "sub":
        rd, rs1, rs2 = map(reg_num, parts[1:4])
        return encode_r(0b0100000, rs2, rs1, 0b000, rd, OP_R)

    if inst == "and":
        rd, rs1, rs2 = map(reg_num, parts[1:4])
        return encode_r(0b0000000, rs2, rs1, 0b111, rd, OP_R)

    if inst == "or":
        rd, rs1, rs2 = map(reg_num, parts[1:4])
        return encode_r(0b0000000, rs2, rs1, 0b110, rd, OP_R)

    if inst == "addi":
        rd = reg_num(parts[1])
        rs1 = reg_num(parts[2])
        imm = int(parts[3])
        return encode_i(imm, rs1, 0b000, rd, OP_I)

    if inst == "ld":
        rd = reg_num(parts[1])
        imm = int(parts[2])
        rs1 = reg_num(parts[3])
        return encode_i(imm, rs1, 0b011, rd, OP_LOAD)

    if inst == "sd":
        rs2 = reg_num(parts[1])
        imm = int(parts[2])
        rs1 = reg_num(parts[3])
        return encode_s(imm, rs2, rs1, 0b011, OP_STORE)

    if inst == "beq":
        rs1 = reg_num(parts[1])
        rs2 = reg_num(parts[2])
        imm = int(parts[3])
        return encode_b(imm, rs2, rs1, 0b000, OP_BRANCH)

    raise ValueError(f"Unsupported instruction: {inst}")


codes = []

with open("instructions_exp.txt", "r") as f:
    for line in f:
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        clean = stripped.split("#")[0].strip()
        codes.append(assemble(clean))


with open("instructions.txt", "w") as f:
    for code in codes:
        for i in reversed(range(4)):
            byte = (code >> (8 * i)) & 0xFF
            f.write(f"{byte:02x}\n")

print("instructions.txt generated.")