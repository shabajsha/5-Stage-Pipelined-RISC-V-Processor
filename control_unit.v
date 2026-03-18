module control_unit(
    input  [6:0] opcode,
    output reg Branch,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

    always @(*) begin

        // Default values
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)

            // R-type
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;
            end

            // I-type (addi)
            7'b0010011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end

            // Load (ld)
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemToReg = 1'b1;
                ALUOp    = 2'b00;
            end

            // Store (sd)
            7'b0100011: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            // Branch (beq)
            7'b1100011: begin
                Branch = 1'b1;
                ALUSrc = 1'b0;
                ALUOp  = 2'b01;
            end

            default: begin
                // Already zero
            end

        endcase
    end

endmodule