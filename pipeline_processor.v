module pipeline_processor(
    input clk,
    input reset
);

// =====================================================
// PC + Instruction Fetch
// =====================================================

wire [63:0] pc_current;
wire [63:0] pc_next;
wire [63:0] pc_plus4;

wire [31:0] instr_if;

assign pc_plus4 = pc_current + 64'd4;

// --- Hazard / Flush / Predictor control wires (declared early for use below) ---
wire PC_write;
wire IF_ID_write;
wire ID_EX_bubble;
wire flush_IF_ID;
wire flush_ID_EX;
wire mispredict;

// --- Branch predictor outputs ---
wire        predict_taken;
wire [63:0] predicted_pc;
wire [63:0] correct_pc;

pc pc_u (
    .clk(clk),
    .reset(reset),
    .write_enable(PC_write),        // stall PC on load-use hazard
    .pc_in(pc_next),
    .pc_out(pc_current)
);

instruction_mem imem_u (
    .addr(pc_current),
    .instr(instr_if)
);


// =====================================================
// IF/ID Pipeline Register
// =====================================================

wire [63:0] IF_ID_pc;
wire [31:0] IF_ID_instr;

// Flush IF/ID on misprediction OR when a prediction is taken
// (a taken prediction means the instruction that entered IF was wrong)
wire flush_IF_ID_final;
assign flush_IF_ID_final = flush_IF_ID | predict_taken;

if_id_reg IF_ID_reg (
    .clk(clk),
    .reset(reset),
    .write_enable(IF_ID_write),         // stall on load-use hazard
    .flush(flush_IF_ID_final),          // flush on mispredict OR predict-taken
    .pc_in(pc_current),                 // store PC (not PC+4) so branch_target = PC + imm
    .instr_in(instr_if),
    .pc_out(IF_ID_pc),
    .instr_out(IF_ID_instr)
);


// =====================================================
// Instruction Decode
// =====================================================

wire [6:0] opcode;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [2:0] funct3;
wire funct7_bit;

assign opcode     = IF_ID_instr[6:0];
assign rd         = IF_ID_instr[11:7];
assign funct3     = IF_ID_instr[14:12];
assign rs1        = IF_ID_instr[19:15];
assign rs2        = IF_ID_instr[24:20];
assign funct7_bit = IF_ID_instr[30];


// =====================================================
// Register File
// =====================================================

wire [63:0] read_data1;
wire [63:0] read_data2;

wire [63:0] write_back_data;

register_file regfile_u (
    .clk(clk),
    .reset(reset),
    .read_reg1(rs1),
    .read_reg2(rs2),
    .write_reg(MEM_WB_rd),
    .write_data(write_back_data),
    .RegWrite(MEM_WB_RegWrite),
    .read_data1(read_data1),
    .read_data2(read_data2)
);


// =====================================================
// Immediate Generator
// =====================================================

wire [63:0] imm_out;

imm_gen immgen_u (
    .instr(IF_ID_instr),
    .imm_out(imm_out)
);


// =====================================================
// Control Unit
// =====================================================

wire RegWrite;
wire MemRead;
wire MemWrite;
wire MemToReg;
wire ALUSrc;
wire Branch;
wire [1:0] ALUOp;

control_unit control_u (
    .opcode(opcode),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemToReg(MemToReg),
    .ALUSrc(ALUSrc),
    .Branch(Branch),
    .ALUOp(ALUOp)
);


// =====================================================
// Hazard Detection Unit
// =====================================================

hazard_detection hazard_u (
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_rd(ID_EX_rd),
    .IF_ID_rs1(rs1),
    .IF_ID_rs2(rs2),
    .PC_write(PC_write),
    .IF_ID_write(IF_ID_write),
    .ID_EX_bubble(ID_EX_bubble)
);


// =====================================================
// ID/EX Pipeline Register
// =====================================================

wire [63:0] ID_EX_pc;
wire [63:0] ID_EX_read_data1;
wire [63:0] ID_EX_read_data2;
wire [63:0] ID_EX_imm;

wire [4:0] ID_EX_rs1;
wire [4:0] ID_EX_rs2;
wire [4:0] ID_EX_rd;

wire [2:0] ID_EX_funct3;
wire ID_EX_funct7_bit;
wire ID_EX_RegWrite;
wire ID_EX_MemRead;
wire ID_EX_MemWrite;
wire ID_EX_MemToReg;
wire ID_EX_ALUSrc;
wire ID_EX_Branch;

wire [1:0] ID_EX_ALUOp;

id_ex_reg ID_EX_reg (
    .clk(clk),
    .reset(reset),
    .bubble(ID_EX_bubble),          // stall/bubble on load-use hazard
    .flush(flush_ID_EX),            // flush on branch misprediction

    .pc_in(IF_ID_pc),
    .read_data1_in(read_data1),
    .read_data2_in(read_data2),
    .imm_in(imm_out),

    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    .funct3_in(funct3),
    .funct7_bit_in(funct7_bit),
    .RegWrite_in(RegWrite),
    .MemRead_in(MemRead),
    .MemWrite_in(MemWrite),
    .MemToReg_in(MemToReg),
    .ALUSrc_in(ALUSrc),
    .Branch_in(Branch),

    .ALUOp_in(ALUOp),

    .pc_out(ID_EX_pc),
    .read_data1_out(ID_EX_read_data1),
    .read_data2_out(ID_EX_read_data2),
    .imm_out(ID_EX_imm),

    .rs1_out(ID_EX_rs1),
    .rs2_out(ID_EX_rs2),
    .rd_out(ID_EX_rd),
    .funct3_out(ID_EX_funct3),
    .funct7_bit_out(ID_EX_funct7_bit),
    .RegWrite_out(ID_EX_RegWrite),
    .MemRead_out(ID_EX_MemRead),
    .MemWrite_out(ID_EX_MemWrite),
    .MemToReg_out(ID_EX_MemToReg),
    .ALUSrc_out(ID_EX_ALUSrc),
    .Branch_out(ID_EX_Branch),

    .ALUOp_out(ID_EX_ALUOp)
);


// =====================================================
// Forwarding Unit
// =====================================================

wire [1:0] ForwardA;
wire [1:0] ForwardB;

forwarding_unit fwd_u (
    .EX_MEM_RegWrite(EX_MEM_RegWrite),
    .MEM_WB_RegWrite(MEM_WB_RegWrite),
    .EX_MEM_rd(EX_MEM_rd),
    .MEM_WB_rd(MEM_WB_rd),
    .ID_EX_rs1(ID_EX_rs1),
    .ID_EX_rs2(ID_EX_rs2),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);


// =====================================================
// ALU Input Forwarding
// =====================================================

wire [63:0] alu_in1;
wire [63:0] alu_in2_reg;
wire [63:0] alu_in2;

assign alu_in1 =
    (ForwardA == 2'b10) ? EX_MEM_alu_result :
    (ForwardA == 2'b01) ? write_back_data :
    ID_EX_read_data1;

assign alu_in2_reg =
    (ForwardB == 2'b10) ? EX_MEM_alu_result :
    (ForwardB == 2'b01) ? write_back_data :
    ID_EX_read_data2;

assign alu_in2 = ID_EX_ALUSrc ? ID_EX_imm : alu_in2_reg;


// =====================================================
// ALU Control
// =====================================================

wire [3:0] alu_ctrl;

alu_control alu_ctrl_u (
    .ALUOp(ID_EX_ALUOp),
    .funct3(ID_EX_funct3),
    .funct7_bit(ID_EX_funct7_bit),
    .alu_control(alu_ctrl)
);


// =====================================================
// ALU
// =====================================================

wire [63:0] alu_result;
wire zero_flag;
wire cout;
wire carry_flag;
wire overflow_flag;

alu_64_bit alu_u (
    .a(alu_in1),
    .b(alu_in2),
    .opcode(alu_ctrl),
    .result(alu_result),
    .cout(cout),
    .carry_flag(carry_flag),
    .overflow_flag(overflow_flag),
    .zero_flag(zero_flag)
);


// =====================================================
// Branch Target & Actual Outcome (resolved in EX)
// =====================================================

wire [63:0] branch_target;
wire        actual_taken;

assign branch_target = ID_EX_pc + ID_EX_imm;
assign actual_taken  = ID_EX_Branch & zero_flag;


// =====================================================
// 2-Bit Branch Predictor (BHT + BTB)
// =====================================================
// Predicts at IF stage using a 64-entry BHT (2-bit saturating counters) and BTB.
// Updates and checks correctness in EX stage once the branch outcome is known.
//
// mispredict    -> flush IF/ID and ID/EX, steer PC to correct_pc
// predict_taken -> steer PC to predicted_pc and squash the sequential fetch (IF/ID only)

branch_predictor bp_u (
    .clk(clk),
    .reset(reset),

    // IF-stage: current PC used to look up prediction
    .pc_if(pc_current),

    // EX-stage: actual outcome used to update BHT/BTB and detect misprediction
    .is_branch_ex(ID_EX_Branch),
    .actual_taken_ex(actual_taken),
    .pc_ex(ID_EX_pc),
    .branch_target_ex(branch_target),
    .pc_plus4_ex(ID_EX_pc + 64'd4),

    // Prediction outputs consumed in IF stage
    .predict_taken(predict_taken),
    .predicted_pc(predicted_pc),

    // Correction outputs consumed when the prediction was wrong
    .mispredict(mispredict),
    .correct_pc(correct_pc)
);


// =====================================================
// Flush Unit
// =====================================================
// On misprediction: flush both IF/ID and ID/EX (2-cycle penalty).
// On a correctly-taken prediction: only IF/ID is flushed (1-cycle penalty),
// handled by flush_IF_ID_final above.

flush_unit flush_u (
    .mispredict(mispredict),
    .flush_IF_ID(flush_IF_ID),
    .flush_ID_EX(flush_ID_EX)
);


// =====================================================
// PC Update
// =====================================================
// Priority: misprediction correction > taken prediction > sequential PC+4

assign pc_next = mispredict    ? correct_pc   :
                 predict_taken ? predicted_pc :
                 pc_plus4;


// =====================================================
// EX/MEM Pipeline Register
// =====================================================

wire [63:0] EX_MEM_alu_result;
wire [63:0] EX_MEM_branch_target;
wire [63:0] EX_MEM_read_data2;

wire EX_MEM_zero;

wire [4:0] EX_MEM_rd;

wire EX_MEM_RegWrite;
wire EX_MEM_MemRead;
wire EX_MEM_MemWrite;
wire EX_MEM_MemToReg;
wire EX_MEM_Branch;


wire [63:0] store_data;

assign store_data =
    (ForwardB == 2'b10) ? EX_MEM_alu_result :
    (ForwardB == 2'b01) ? write_back_data :
    ID_EX_read_data2;

ex_mem_reg EX_MEM_reg (
    .clk(clk),
    .reset(reset),

    .alu_result_in(alu_result),
    .branch_target_in(branch_target),
    .read_data2_in(store_data),

    .zero_in(zero_flag),
    .rd_in(ID_EX_rd),

    .RegWrite_in(ID_EX_RegWrite),
    .MemRead_in(ID_EX_MemRead),
    .MemWrite_in(ID_EX_MemWrite),
    .MemToReg_in(ID_EX_MemToReg),
    .Branch_in(ID_EX_Branch),

    .alu_result_out(EX_MEM_alu_result),
    .branch_target_out(EX_MEM_branch_target),
    .read_data2_out(EX_MEM_read_data2),

    .zero_out(EX_MEM_zero),
    .rd_out(EX_MEM_rd),

    .RegWrite_out(EX_MEM_RegWrite),
    .MemRead_out(EX_MEM_MemRead),
    .MemWrite_out(EX_MEM_MemWrite),
    .MemToReg_out(EX_MEM_MemToReg),
    .Branch_out(EX_MEM_Branch)
);


// =====================================================
// Data Memory
// =====================================================

wire [63:0] mem_read_data;

data_memory dmem_u (
    .clk(clk),
    .reset(reset),
    .address(EX_MEM_alu_result),
    .write_data(EX_MEM_read_data2),
    .MemRead(EX_MEM_MemRead),
    .MemWrite(EX_MEM_MemWrite),
    .read_data(mem_read_data)
);


// =====================================================
// MEM/WB Pipeline Register
// =====================================================

wire [63:0] MEM_WB_mem_read_data;
wire [63:0] MEM_WB_alu_result;

wire [4:0] MEM_WB_rd;

wire MEM_WB_RegWrite;
wire MEM_WB_MemToReg;

mem_wb_reg MEM_WB_reg (
    .clk(clk),
    .reset(reset),

    .mem_read_data_in(mem_read_data),
    .alu_result_in(EX_MEM_alu_result),

    .rd_in(EX_MEM_rd),

    .RegWrite_in(EX_MEM_RegWrite),
    .MemToReg_in(EX_MEM_MemToReg),

    .mem_read_data_out(MEM_WB_mem_read_data),
    .alu_result_out(MEM_WB_alu_result),

    .rd_out(MEM_WB_rd),

    .RegWrite_out(MEM_WB_RegWrite),
    .MemToReg_out(MEM_WB_MemToReg)
);


// =====================================================
// Writeback
// =====================================================

assign write_back_data =
    MEM_WB_MemToReg ?
    MEM_WB_mem_read_data :
    MEM_WB_alu_result;

endmodule