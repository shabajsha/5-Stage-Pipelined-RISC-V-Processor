module instruction_mem(
    input  [63:0] addr,
    output [31:0] instr
);

    reg [7:0] imem [0:4095];
    wire [11:0] addr_low;

    assign addr_low = addr[11:0];

    initial begin
        $readmemh("instructions.txt", imem);
    end

    assign instr = {
        imem[addr_low],
        imem[addr_low + 12'd1],
        imem[addr_low + 12'd2],
        imem[addr_low + 12'd3]
    };

endmodule