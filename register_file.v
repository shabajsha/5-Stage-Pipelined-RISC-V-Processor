module register_file(
    input clk,
    input reset,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [63:0] write_data,
    input RegWrite,
    output [63:0] read_data1,
    output [63:0] read_data2
);

    reg [63:0] reg_array [0:31];
    integer i;

    // Reset and Write
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                reg_array[i] <= 64'd0;
        end
        else begin
            if (RegWrite && (write_reg != 5'd0))
                reg_array[write_reg] <= write_data;

            // Ensure x0 always remains zero
            reg_array[0] <= 64'd0;
        end
    end

    // Combinational Read with WB->ID bypass
    // When WB is writing the same register that ID is reading in the same cycle,
    // the non-blocking assignment hasn't updated reg_array yet, so we forward
    // write_data directly to avoid reading a stale value.
    assign read_data1 = (RegWrite && (write_reg != 5'd0) && (write_reg == read_reg1))
                        ? write_data : reg_array[read_reg1];

    assign read_data2 = (RegWrite && (write_reg != 5'd0) && (write_reg == read_reg2))
                        ? write_data : reg_array[read_reg2];

endmodule