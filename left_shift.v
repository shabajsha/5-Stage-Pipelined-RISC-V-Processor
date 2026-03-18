module left_shift
    (input  [63:0] a,
     input  [63:0] shamt,
     output [63:0] y);

    wire [63:0] w1;
    wire [63:0] w2;
    wire [63:0] w4;
    wire [63:0] w8;
    wire [63:0] w16;
    wire [63:0] w32;

    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : L1
            if (i == 0)
                mux2_1 m(a[i], 1'b0, shamt[0], w1[i]);
            else
                mux2_1 m(a[i], a[i-1], shamt[0], w1[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : L2
            if (i < 2)
                mux2_1 m(w1[i], 1'b0, shamt[1], w2[i]);
            else
                mux2_1 m(w1[i], w1[i-2], shamt[1], w2[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : L4
            if (i < 4)
                mux2_1 m(w2[i], 1'b0, shamt[2], w4[i]);
            else
                mux2_1 m(w2[i], w2[i-4], shamt[2], w4[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : L8
            if (i < 8)
                mux2_1 m(w4[i], 1'b0, shamt[3], w8[i]);
            else
                mux2_1 m(w4[i], w4[i-8], shamt[3], w8[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : L16
            if (i < 16)
                mux2_1 m(w8[i], 1'b0, shamt[4], w16[i]);
            else
                mux2_1 m(w8[i], w8[i-16], shamt[4], w16[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : L32
            if (i < 32)
                mux2_1 m(w16[i], 1'b0, shamt[5], y[i]);
            else
                mux2_1 m(w16[i], w16[i-32], shamt[5], y[i]);
        end
    endgenerate

endmodule
