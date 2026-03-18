module right_shift_arithmetic
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
        for (i = 0; i < 64; i = i + 1) begin : A1
            if (i == 63)
                mux2_1 m(a[i], a[63], shamt[0], w1[i]);
            else
                mux2_1 m(a[i], a[i+1], shamt[0], w1[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : A2
            if (i > 61)
                mux2_1 m(w1[i], a[63], shamt[1], w2[i]);
            else
                mux2_1 m(w1[i], w1[i+2], shamt[1], w2[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : A4
            if (i > 59)
                mux2_1 m(w2[i], a[63], shamt[2], w4[i]);
            else
                mux2_1 m(w2[i], w2[i+4], shamt[2], w4[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : A8
            if (i > 55)
                mux2_1 m(w4[i], a[63], shamt[3], w8[i]);
            else
                mux2_1 m(w4[i], w4[i+8], shamt[3], w8[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : A16
            if (i > 47)
                mux2_1 m(w8[i], a[63], shamt[4], w16[i]);
            else
                mux2_1 m(w8[i], w8[i+16], shamt[4], w16[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : A32
            if (i > 31)
                mux2_1 m(w16[i], a[63], shamt[5], y[i]);
            else
                mux2_1 m(w16[i], w16[i+32], shamt[5], y[i]);
        end
    endgenerate

endmodule
