module processor(
    input clk,
    input reset
);

    // ================= PC =================
    wire [63:0] pc_current;
    wire [63:0] pc_next;
    wire [63:0] pc_plus4;
    wire [63:0] branch_target;

    pc pc_u (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_current)
    );

    assign pc_plus4 = pc_current + 64'd4;

    // ================= Instruction Memory =================
    wire [31:0] instr;

    instruction_mem imem_u (
        .addr(pc_current),
        .instr(instr)
    );

    // ================= Instruction Fields =================
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire funct7_bit;

    assign opcode      = instr[6:0];
    assign rd          = instr[11:7];
    assign funct3      = instr[14:12];
    assign rs1         = instr[19:15];
    assign rs2         = instr[24:20];
    assign funct7_bit  = instr[30];

    // ================= Control Unit =================
    wire Branch, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite;
    wire [1:0] ALUOp;

    control_unit control_u (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );

    // ================= Register File =================
    wire [63:0] read_data1, read_data2;
    wire [63:0] write_back_data;

    register_file regfile_u (
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(write_back_data),
        .RegWrite(RegWrite),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ================= Immediate Generator =================
    wire [63:0] imm_out;

    imm_gen imm_u (
        .instr(instr),
        .imm_out(imm_out)
    );

    // ================= ALU Control =================
    wire [3:0] alu_ctrl;

    alu_control alu_control_u (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_bit(funct7_bit),
        .alu_control(alu_ctrl)
    );

    // ================= ALU =================
    wire [63:0] alu_in2;
    wire [63:0] alu_result;
    wire zero_flag;
    wire cout, carry_flag, overflow_flag;

    assign alu_in2 = (ALUSrc) ? imm_out : read_data2;

    alu_64_bit alu_u (
        .a(read_data1),
        .b(alu_in2),
        .opcode(alu_ctrl),
        .result(alu_result),
        .cout(cout),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag)
    );

    // ================= Data Memory =================
    wire [63:0] mem_read_data;

    data_memory dmem_u (
        .clk(clk),
        .reset(reset),
        .address(alu_result),
        .write_data(read_data2),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(mem_read_data)
    );

    // ================= Write Back =================
    assign write_back_data = (MemToReg) ? mem_read_data : alu_result;

    // ================= Branch Logic =================
    assign branch_target = pc_current + imm_out;
    assign pc_next = (Branch && zero_flag) ? branch_target : pc_plus4;

endmodule