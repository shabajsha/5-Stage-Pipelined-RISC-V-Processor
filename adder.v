module adder
    (input  wire [63:0] a,
     input  wire [63:0] b,
     input  wire        cin,
     output wire [63:0] sum,
     output wire        cout,
     output wire        overflow);

    wire [64:0] carry;
    wire [63:0] axb;
    wire [63:0] ab;
    wire [63:0] cin_axb;

    buf (carry[0], cin);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin: gen_add

            xor_op x1 (a[i], b[i], axb[i]);
            xor_op x2 (axb[i], carry[i], sum[i]);

            and_op a1 (a[i], b[i], ab[i]);
            and_op a2 (carry[i], axb[i], cin_axb[i]);

            or_op  o1 (ab[i], cin_axb[i], carry[i+1]);

        end
    endgenerate

    buf (cout, carry[64]);
    xor_op ovf (carry[63], carry[64], overflow);

endmodule
