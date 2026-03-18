module alu_64_bit
    (input  [63:0] a,
     input  [63:0] b,
     input  [3:0]  opcode,
     output reg [63:0] result,
     output reg cout,
     output reg carry_flag,
     output reg overflow_flag,
     output reg zero_flag);

    wire [63:0] add_res;
    wire add_cout, add_ovf;

    wire [63:0] sub_res;
    wire sub_cout, sub_ovf;

    wire [63:0] and_res;
    wire [63:0] or_res;
    wire [63:0] xor_res;

    wire [63:0] sll_res;
    wire [63:0] srl_res;
    wire [63:0] sra_res;

    wire [63:0] slt_res;
    wire [63:0] sltu_res;

    adder add_u (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(add_res),
        .cout(add_cout),
        .overflow(add_ovf)
    );

    subtractor sub_u (
        .a(a),
        .b(b),
        .diff(sub_res),
        .cout(sub_cout),
        .overflow(sub_ovf)
    );

    and_64bit and_u (.a(a), .b(b), .y(and_res));
    or_64bit  or_u  (.a(a), .b(b), .y(or_res));
    xor_64bit xor_u (.a(a), .b(b), .y(xor_res));

    left_shift  sll_u (.a(a), .shamt(b), .y(sll_res));
    right_shift srl_u (.a(a), .shamt(b), .y(srl_res));
    right_shift_arithmetic sra_u (.a(a), .shamt(b), .y(sra_res));

    slt  slt_u  (.a(a), .b(b), .y(slt_res));
    sltu sltu_u (.a(a), .b(b), .y(sltu_res));

    always @(*) begin
        result = 64'b0;
        cout = 1'b0;
        carry_flag = 1'b0;
        overflow_flag = 1'b0;

        case (opcode)
            4'b0000: begin
                result = add_res;
                cout = add_cout;
                carry_flag = add_cout;
                overflow_flag = add_ovf;
            end

            4'b1000: begin
                result = sub_res;
                cout = sub_cout;
                carry_flag = ~sub_cout;
                overflow_flag = sub_ovf;
            end

            4'b0001: result = sll_res;
            4'b0010: result = slt_res;
            4'b0011: result = sltu_res;
            4'b0100: result = xor_res;
            4'b0101: result = srl_res;
            4'b0110: result = or_res;
            4'b0111: result = and_res;
            4'b1101: result = sra_res;

            default: result = 64'b0;
        endcase

        if (result == 64'b0)
            zero_flag = 1'b1;
        else
            zero_flag = 1'b0;
    end

endmodule
