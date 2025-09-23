`timescale 1ns/1ps

module control_tb;

    // Parameters
    localparam RTYPE = 7'b0110011;
    localparam IMTYPE = 7'b0010011;
    localparam ILTYPE = 7'b0000011;
    localparam STYPE = 7'b0100011;
    localparam BTYPE = 7'b1100011;
    localparam UTYPE = 7'b0110111;
    localparam JTYPE = 7'b1101111;

    // Signals
    logic clk;
    logic [31:0] instr;
    logic branch;
    logic memread;
    logic memtoreg;
    logic [1:0] alu_cop;
    logic memwrite;
    logic alusrc;
    logic regwrite;

    // DUT instantiation
    control dut (
        .clk(clk),
        .instr(instr),
        .branch(branch),
        .memread(memread),
        .memtoreg(memtoreg),
        .alu_cop(alu_cop),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .regwrite(regwrite)
    );

    // Clock generation
    always #5 clk = ~clk;

    task test_instr(
        input [6:0] opcode,
        input string name,
        input logic expected_branch,
        input logic expected_memread,
        input logic expected_memtoreg,
        input [1:0] expected_alu_cop,
        input logic expected_memwrite,
        input logic expected_alusrc,
        input logic expected_regwrite
    );
        begin
            instr = {25'd0, opcode};
            @(posedge clk); #1;

            $display("\n--- Testing %s (opcode: %b) ---", name, opcode);
            $display("Signal      | branch | memread | memtoreg | alu_cop | memwrite | alusrc | regwrite");
            $display("------------|--------|---------|----------|---------|----------|--------|----------");

            $display("Actual      |   %0b    |    %0b    |    %0b     |   %02b    |    %0b     |   %0b    |    %0b",
                branch, memread, memtoreg, alu_cop, memwrite, alusrc, regwrite);

            $display("Expected    |   %0b    |    %0b    |    %0b     |   %02b    |    %0b     |   %0b    |    %0b",
                expected_branch, expected_memread, expected_memtoreg, expected_alu_cop,
                expected_memwrite, expected_alusrc, expected_regwrite);

            // Check outputs
            if (branch      !== expected_branch   ||
                memread     !== expected_memread  ||
                memtoreg    !== expected_memtoreg ||
                alu_cop     !== expected_alu_cop  ||
                memwrite    !== expected_memwrite ||
                alusrc      !== expected_alusrc   ||
                regwrite    !== expected_regwrite) begin

                $error("Test FAILED for %s\n", name);
            end else begin
                $display("Test PASSED for %s\n", name);
            end
        end
    endtask


    initial begin
        $display("\n=== Starting Control Unit Testbench ===\n");
        clk = 0;
        instr = 32'd0;

        test_instr(RTYPE , "RTYPE" , 0, 0, 0, 2'b10, 0, 0, 1);
        test_instr(IMTYPE, "IMTYPE", 0, 0, 0, 2'b10, 0, 1, 1);
        test_instr(ILTYPE, "ILTYPE", 0, 1, 1, 2'b00, 0, 1, 1);
        test_instr(STYPE , "STYPE" , 0, 0, 0, 2'b00, 1, 1, 0);
        test_instr(BTYPE , "BTYPE" , 1, 0, 0, 2'b01, 0, 1, 0);
        test_instr(UTYPE , "UTYPE" , 0, 0, 1, 2'b00, 0, 1, 1);
        test_instr(JTYPE , "JTYPE" , 0, 0, 1, 2'b00, 0, 1, 1);

        $display("=== Control Unit Testbench Finished ===\n");
        $finish;
    end


endmodule