`timescale 1 ns / 1 ps

module regfile_tb;

    logic clk;
    logic regwrite;
    logic [31:0] instr;
    logic [31:0] write_data;
    logic [31:0] readout1;
    logic [31:0] readout2;

    regfile dut (
        .clk(clk),
        .regwrite(regwrite),
        .instr(instr),
        .write_data(write_data),
        .readout1(readout1),
        .readout2(readout2)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    logic [31:0] readout1_val;
    logic [31:0] readout2_val;

    task apply_stimulus(
        input logic [31:0] write_instr,
        input logic [31:0] write_val,
        input logic [31:0] read_instr1,
        input logic [31:0] read_instr2,
        input logic [31:0] expected_readout1,
        input logic [31:0] expected_readout2,
        input string test_name
    );
        begin
            @(negedge clk);

            regwrite = 1;
            instr = write_instr;
            write_data = write_val;
            #10;

            regwrite = 0;
            instr = read_instr1;
            #10;
            readout1_val = readout1;

            instr = read_instr2;
            #10;
            readout2_val = readout2;

            if (readout1_val == expected_readout1 && readout2_val == expected_readout2) begin
                $display("[%s] -> PASSED: write_instr=%h write_val=%h read_instr1=%h expected_readout1=%h read_instr2=%h expected_readout2=%h",
                         test_name, write_instr, write_val, read_instr1, expected_readout1, read_instr2, expected_readout2);
            end else begin
                $display("[%s] -> FAILED: write_instr=%h write_val=%h read_instr1=%h readout1=%h expected_readout1=%h read_instr2=%h readout2=%h expected_readout2=%h",
                         test_name, write_instr, write_val, read_instr1, readout1_val, expected_readout1, read_instr2, readout2_val, expected_readout2);
            end
        end
    endtask

    initial begin
        $display("=== regfile TESTBENCH ===");

        regwrite = 0;
        instr = 0;
        write_data = 0;

        repeat (2) @(posedge clk);

        // Test case 1: Write value to register 5, read from registers 1 and 2
        apply_stimulus(32'h00000005, 32'h12345678, 32'h00200005, 32'h00400005, 32'h12345678, 32'h0, "Write to reg 5, read from reg 5 and 2");

        // Test case 2: Write value to register 7, read from registers 1 and 3
        apply_stimulus(32'h00700007, 32'hA1B2C3D4, 32'h00200007, 32'h00400007, 32'h0, 32'h0, "Write to reg 7, read from reg 7 and 3");

        // Test case 3: Write value to register 10, read from registers 10 and 5
        apply_stimulus(32'h00A0000A, 32'hDEADBEEF, 32'h0020000A, 32'h0040000A, 32'hDEADBEEF, 32'h0, "Write to reg 10, read from reg 10 and 5");

        // Test case 4: Write value to register 3, read from registers 2 and 4
        apply_stimulus(32'h00300003, 32'hCAFEBABE, 32'h00200003, 32'h00400003, 32'hCAFEBABE, 32'h0, "Write to reg 3, read from reg 2 and 4");

        // Test case 5: Write value to register 15, read from registers 6 and 8
        apply_stimulus(32'h00F0000F, 32'hBADC0FFE, 32'h0020000F, 32'h0040000F, 32'hBADC0FFE, 32'h0, "Write to reg 15, read from reg 6 and 8");

        // Test case 6: Write value to register 0, read from registers 3 and 9
        apply_stimulus(32'h00000000, 32'h00000000, 32'h00200000, 32'h00400000, 32'h0, 32'h0, "Write to reg 0, read from reg 3 and 9");

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule
