module ex_mem_reg(
    input clk,
    input reset,

    input [63:0] alu_result_in,
    input [63:0] branch_target_in,
    input [63:0] read_data2_in,

    input zero_in,
    input [4:0] rd_in,

    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemToReg_in,
    input Branch_in,

    output reg [63:0] alu_result_out,
    output reg [63:0] branch_target_out,
    output reg [63:0] read_data2_out,

    output reg zero_out,
    output reg [4:0] rd_out,

    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    output reg Branch_out
);

always @(posedge clk) begin
    if (reset) begin
        alu_result_out <= 0;
        branch_target_out <= 0;
        read_data2_out <= 0;

        zero_out <= 0;
        rd_out <= 0;

        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemToReg_out <= 0;
        Branch_out <= 0;
    end
    else begin
        alu_result_out <= alu_result_in;
        branch_target_out <= branch_target_in;
        read_data2_out <= read_data2_in;

        zero_out <= zero_in;
        rd_out <= rd_in;

        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemToReg_out <= MemToReg_in;
        Branch_out <= Branch_in;
    end
end

endmodule