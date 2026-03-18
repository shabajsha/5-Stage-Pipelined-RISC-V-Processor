module hazard_detection(
    input        ID_EX_MemRead,
    input  [4:0] ID_EX_rd,
    input  [4:0] IF_ID_rs1,
    input  [4:0] IF_ID_rs2,

    output reg PC_write,
    output reg IF_ID_write,
    output reg ID_EX_bubble
);

    always @(*) begin
        PC_write     = 1'b1;
        IF_ID_write  = 1'b1;
        ID_EX_bubble = 1'b0;

        if (ID_EX_MemRead &&
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))) begin
            PC_write     = 1'b0;
            IF_ID_write  = 1'b0;
            ID_EX_bubble = 1'b1;
        end
    end

endmodule
