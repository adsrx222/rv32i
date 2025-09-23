`timescale 1 ns / 1 ps

module data_mem_unit_tb;

    logic clk;
    logic memwrite;
    logic memread;
    logic [31:0] addr;
    logic [31:0] write_data;
    logic [31:0] read_data;

    data_mem_unit #(
        .DMEM_SIZE(1024)
    ) dut (
        .clk(clk),
        .memwrite(memwrite),
        .memread(memread),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    string result_msg;

    task apply_stimulus;
        input logic memwrite_in;
        input logic memread_in;
        input logic [31:0] addr_in;
        input logic [31:0] write_data_in;
        input logic [31:0] expected_read_data;
        begin
            @(negedge clk);
            memwrite = memwrite_in;
            memread = memread_in;
            addr = addr_in;
            write_data = write_data_in;

            @(posedge clk);
            #5;

            if (memread && (read_data === expected_read_data)) begin
                result_msg = "PASS";
            end else if (memread && (read_data !== expected_read_data)) begin
                result_msg = "FAIL";
            end else begin
                result_msg = "N/A";
            end

            $display("memwrite=%0d | memread=%0d | addr=0x%0h | write_data=0x%0h | read_data=0x%0h | result: %-15s",
                     memwrite, memread, addr, write_data, read_data, result_msg);
        end
    endtask

    initial begin
        $display("=== data_mem_unit TESTBENCH ===");

        // Initialize all inputs
        memwrite = 1'b0;
        memread = 1'b0;
        addr = 32'b0;
        write_data = 32'b0;

        repeat (5) @(posedge clk);

        // Test 1: Write to memory (memwrite = 1)
        apply_stimulus(1, 0, 32'd100, 32'd999, 32'b0);  // Writing 999 at address 100
        // Test 2: Read from memory (memread = 1)
        apply_stimulus(0, 1, 32'd100, 32'b0, 32'd999);  // Expect to read 999 from address 100

        // Test 3: Write to another memory location
        apply_stimulus(1, 0, 32'd200, 32'd456, 32'b0);  // Writing 456 at address 200
        // Test 4: Read from the new memory location
        apply_stimulus(0, 1, 32'd200, 32'b0, 32'd456);  // Expect to read 456 from address 200

        // Test 5: Read from an uninitialized memory location (should be 0)
        apply_stimulus(0, 1, 32'd300, 32'b0, 32'b0);  // Expect to read 0 from address 300

        // Test 6: Write and then read back from a negative address (out of bounds)
        apply_stimulus(1, 0, 32'd1025, 32'd111, 32'b0);  // Invalid address
        apply_stimulus(0, 1, 32'd1025, 32'b0, 32'b0);  // Expect to read 0 from invalid address

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule