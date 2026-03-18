module subtractor
    (input  [63:0] a,
     input  [63:0] b,
     output [63:0] diff,
     output        cout,
     output        overflow);

    wire [63:0] b_inv;

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
        .sum(diff),
        .cout(cout),
        .overflow(overflow)
    );

endmodule
