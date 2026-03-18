module alu_control(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input        funct7_bit,
    output reg [3:0] alu_control
);

    always @(*) begin
        alu_control = 4'b0000;

        case (ALUOp)

            // 00 → ADD (addi, ld, sd)
            2'b00: begin
                alu_control = 4'b0000;
            end

            // 01 → SUB (beq)
            2'b01: begin
                alu_control = 4'b1000;
            end

            // 10 → R-type
            2'b10: begin
                case (funct3)

                    3'b000: begin
                        if (funct7_bit == 1'b1)
                            alu_control = 4'b1000;  // SUB
                        else
                            alu_control = 4'b0000;  // ADD
                    end

                    3'b111: alu_control = 4'b0111;  // AND
                    3'b110: alu_control = 4'b0110;  // OR
                    3'b010: alu_control = 4'b0010;  // SLT

                    default: alu_control = 4'b0000;
                endcase
            end

            default: begin
                alu_control = 4'b0000;
            end

        endcase
    end

endmodule