module branch_predictor(
    input        clk,
    input        reset,

    input [63:0] pc_if,
    output        predict_taken,
    output [63:0] predicted_pc,

    input        is_branch_ex,
    input        actual_taken_ex,
    input [63:0] pc_ex,
    input [63:0] branch_target_ex,
    input [63:0] pc_plus4_ex,

    output        mispredict,
    output [63:0] correct_pc
);

    // ================= BHT + BTB =================
    // 64-entry table indexed by PC[7:2]
    // BHT: 2-bit saturating counter per entry
    //   00 Strongly Not Taken
    //   01 Weakly Not Taken
    //   10 Weakly Taken
    //   11 Strongly Taken
    // BTB: stores the branch target per entry

    reg [1:0]  BHT [0:63];
    reg [63:0] BTB [0:63];

    integer i;

    wire [5:0] index_if = pc_if[7:2];
    wire [5:0] index_ex = pc_ex[7:2];

    // ================= Prediction (IF stage) =================
    assign predict_taken = BHT[index_if][1];
    assign predicted_pc  = BTB[index_if];

    // ================= Misprediction (EX stage) =================
    assign mispredict = is_branch_ex && (actual_taken_ex != BHT[index_ex][1]);
    assign correct_pc = actual_taken_ex ? branch_target_ex : pc_plus4_ex;

    // ================= Update (EX stage) =================
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1) begin
                BHT[i] <= 2'b01;
                BTB[i] <= 64'd0;
            end
        end
        else if (is_branch_ex) begin
            BTB[index_ex] <= branch_target_ex;
            if (actual_taken_ex) begin
                if (BHT[index_ex] != 2'b11)
                    BHT[index_ex] <= BHT[index_ex] + 1;
            end
            else begin
                if (BHT[index_ex] != 2'b00)
                    BHT[index_ex] <= BHT[index_ex] - 1;
            end
        end
    end

endmodule
