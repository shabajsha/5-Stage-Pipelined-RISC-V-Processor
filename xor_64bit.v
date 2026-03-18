module xor_64bit(input [63:0] a, input [63:0] b, output [63:0] y);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : g_xor
            xor_op u (a[i], b[i], y[i]);
        end
    endgenerate
endmodule
