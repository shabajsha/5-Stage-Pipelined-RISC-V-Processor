module pipe_tb;

reg clk;
reg reset;

integer cycle_count;
integer file;
integer i;

// instantiate processor
pipeline_processor uut(
    .clk(clk),
    .reset(reset)
);



// clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end



// reset
initial begin
    reset = 1;
    cycle_count = 0;
    #20;
    reset = 0;
end



// cycle counter + dynamic stop
always @(posedge clk) begin
    cycle_count = cycle_count + 1;

    // Stop when PC has moved past the last instruction in the program.
    // The testbench appends 4 dummy NOPs after the last real instruction to
    // drain the pipeline, so we wait until the PC is fetching beyond those.
    // 19 instructions total -> last byte address = 18*4 = 72.
    // After the final dummy is fetched, PC = 76.  Give one extra cycle for WB.
    if (!reset && uut.pc_current >= 64'd80) begin

        $display("Program finished");
        $display("Total cycles = %d", cycle_count);

        // open register file
        file = $fopen("register_file.txt","w");

        for(i = 0; i < 32; i = i + 1) begin
            $fdisplay(file,"%016h", uut.regfile_u.reg_array[i]);
        end

        $fdisplay(file,"%d", cycle_count);

        $fclose(file);

        $finish;
    end
end

endmodule