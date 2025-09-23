`timescale 1 ns / 1 ps

module data_mem_mux_tb;

    logic clk;
    logic memtoreg;
    logic [31:0] read_data;
    logic [31:0] alu_result;
    logic [31:0] write_data;

    data_mem_mux dut (
        .clk(clk),
        .memtoreg(memtoreg),
        .alu_result(alu_result),
        .read_data(read_data),
        .write_data(write_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    string result_msg;

    task apply_stimulus(
        input logic a,
        input logic [31:0] b,
        input logic [31:0] c,
        input logic [31:0] expected
    );
        begin
          	@(negedge clk);
            memtoreg = a;
            alu_result = b;
            read_data = c;

            @(posedge clk);
            #5;

            if (write_data === expected)
                result_msg = "PASS";
            else
                result_msg = $sformatf("FAIL (exp=0x%0b)", expected);

            $display("TEST:     %-0d      |     %0d     |       %0d     |       %0d     |       %-15s", memtoreg, alu_result, read_data, expected, result_msg);
        end
    endtask

    // Test sequence
    initial begin
      	$display("=== data_mem_mux TESTBENCH ===");

        // Initialize all inputs
        memtoreg = 1'b0;
        read_data = 32'b0;
        alu_result = 32'b0;

        // Wait 2 cycles to stabilize
        repeat (2) @(posedge clk);

        // Test memtoreg = 0
        apply_stimulus(0, 32'd122, 32'd332, 32'd122);

        // Test memtoreg = 1
        apply_stimulus(1, 32'd122, 32'd332, 32'd332);

        // Test memtoreg = 0
        apply_stimulus(0, -32'd8, -32'd72, -32'd8);

        // Test memtoreg = 1
        apply_stimulus(1, -32'd8, -32'd72, -32'd72);

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule