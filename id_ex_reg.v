module id_ex_reg(
    input clk,
    input reset,
    input bubble,
    input flush,

    input [63:0] pc_in,
    input [63:0] read_data1_in,
    input [63:0] read_data2_in,
    input [63:0] imm_in,

    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input [2:0] funct3_in,
    input funct7_bit_in,
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemToReg_in,
    input ALUSrc_in,
    input Branch_in,

    input [1:0] ALUOp_in,

    output reg [63:0] pc_out,
    output reg [63:0] read_data1_out,
    output reg [63:0] read_data2_out,
    output reg [63:0] imm_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,
    output reg funct7_bit_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    output reg ALUSrc_out,
    output reg Branch_out,

    output reg [1:0] ALUOp_out
);

always @(posedge clk) begin
    if (reset || bubble || flush) begin
        pc_out <= 0;
        read_data1_out <= 0;
        read_data2_out <= 0;
        imm_out <= 0;

        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;
        funct3_out <= 3'b000;
        funct7_bit_out <= 1'b0;
        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemToReg_out <= 0;
        ALUSrc_out <= 0;
        Branch_out <= 0;

        ALUOp_out <= 0;
    end
    else begin
        pc_out <= pc_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        imm_out <= imm_in;

        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        funct3_out <= funct3_in;
        funct7_bit_out <= funct7_bit_in;
        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemToReg_out <= MemToReg_in;
        ALUSrc_out <= ALUSrc_in;
        Branch_out <= Branch_in;

        ALUOp_out <= ALUOp_in;
    end
end

endmodule