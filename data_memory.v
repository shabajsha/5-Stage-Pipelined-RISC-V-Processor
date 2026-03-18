module data_memory(
    input clk,
    input reset,
    input [63:0] address,
    input [63:0] write_data,
    input MemRead,
    input MemWrite,
    output reg [63:0] read_data
);

    reg [7:0] dmem [0:1023];
    integer i;

    wire [9:0] address_low;
    assign address_low = address[9:0];

    // Sequential write + reset
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                dmem[i] <= 8'h00;
        end
        else if (MemWrite && address_low <= 10'd1016) begin
            dmem[address_low]       <= write_data[63:56];
            dmem[address_low + 1]   <= write_data[55:48];
            dmem[address_low + 2]   <= write_data[47:40];
            dmem[address_low + 3]   <= write_data[39:32];
            dmem[address_low + 4]   <= write_data[31:24];
            dmem[address_low + 5]   <= write_data[23:16];
            dmem[address_low + 6]   <= write_data[15:8];
            dmem[address_low + 7]   <= write_data[7:0];
        end
    end

    // Combinational read
    always @(*) begin
        if (MemRead && address_low <= 10'd1016) begin
            read_data = {
                dmem[address_low],
                dmem[address_low + 1],
                dmem[address_low + 2],
                dmem[address_low + 3],
                dmem[address_low + 4],
                dmem[address_low + 5],
                dmem[address_low + 6],
                dmem[address_low + 7]
            };
        end
        else begin
            read_data = 64'd0;
        end
    end

endmodule