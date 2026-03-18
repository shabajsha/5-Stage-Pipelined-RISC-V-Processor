module sltu
    (input  [63:0] a,
     input  [63:0] b,
     output [63:0] y);

    wire [63:0] b_inv;
    wire [63:0] sum;
    wire        cout;
    wire        ovf;
    wire        less;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : inv
            not (b_inv[i], b[i]);
        end
    endgenerate

    adder sub (
        .a(a),
        .b(b_inv),
        .cin(1'b1),
        .sum(sum),
        .cout(cout),
        .overflow(ovf)
    );

    not (less, cout);

    genvar j;
    generate
        for (j = 0; j < 64; j = j + 1) begin : out
            if (j == 0)
                buf (y[j], less);
            else
                buf (y[j], 1'b0);
        end
    endgenerate

endmodule
