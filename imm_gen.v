module imm_gen(
    input  [31:0] instr,
    output reg [63:0] imm_out
);

    wire [6:0] opcode;
    assign opcode = instr[6:0];

    always @(*) begin
        imm_out = 64'd0;

        case (opcode)

            // I-type (addi, ld)
            7'b0010011,
            7'b0000011: begin
                imm_out = {{52{instr[31]}}, instr[31:20]};
            end

            // S-type (sd)
            7'b0100011: begin
                imm_out = {{52{instr[31]}},
                           instr[31:25],
                           instr[11:7]};
            end

            // B-type (beq)
            7'b1100011: begin
                imm_out = {{51{instr[31]}},
                           instr[31],
                           instr[7],
                           instr[30:25],
                           instr[11:8],
                           1'b0};
            end

            default: begin
                imm_out = 64'd0;
            end

        endcase
    end

endmodule