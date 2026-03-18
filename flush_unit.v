module flush_unit(
    input mispredict,

    output reg flush_IF_ID,
    output reg flush_ID_EX
);

    always @(*) begin
        flush_IF_ID = 1'b0;
        flush_ID_EX = 1'b0;

        if (mispredict) begin
            flush_IF_ID = 1'b1;
            flush_ID_EX = 1'b1;
        end
    end

endmodule
