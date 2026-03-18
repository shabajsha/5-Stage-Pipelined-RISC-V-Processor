module pc(
    input clk,
    input reset,
    input write_enable,
    input  [63:0] pc_in,
    output reg [63:0] pc_out
);

    always @(posedge clk) begin
        if (reset)
            pc_out <= 64'd0;
        else if (write_enable)
            pc_out <= pc_in;
    end

endmodule