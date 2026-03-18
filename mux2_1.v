module mux2_1(input d0, input d1, input sel, output y);
    wire nsel;
    wire w0;
    wire w1;

    not (nsel, sel);
    and (w0, d0, nsel);
    and (w1, d1, sel);
    or  (y, w0, w1);
endmodule
