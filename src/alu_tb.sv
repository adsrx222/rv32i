`timescale 1ns / 1ps

module alu_tb;

    // Clock and inputs
    logic clk;
    logic [3:0] aluop;
    logic [31:0] rs1;
    logic [31:0] rs2;
    
    // Output from DUT
    logic zero;
    logic [31:0] out;

    // Instantiate the DUT
    alu dut (
      	.clk(clk),
        .rs1(rs1),
    	.rs2(rs2),
        .aluop(aluop),
    	.zero(zero),
    	.out(out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    task apply_stimulus (
        input logic [3:0] code,
        input logic [31:0] reg1,
        input logic [31:0] reg2,
        input logic [31:0] expected_out,
        input string test_name
    );

    string result_msg;

    begin
        @(negedge clk);
        rs1 = reg1;
        rs2 = reg2;
        aluop = code;

        @(posedge clk);
        #5;

        if (out === expected_out)
            result_msg = "PASS";
        else
            result_msg = $sformatf("FAIL (exp=%0d)", expected_out);

        $display("%-25s | %d | %d  | %4b | %d | %-15s", test_name, rs1, rs1, aluop, out, result_msg);
    end
        
    endtask

    initial begin
        $display("=== ALU Testbench ===");

        rs1 = 0;
        rs2 = 0;
        aluop = 0;

        //Wait 2 cycles for the DUT to initialize
        repeat (2) @(posedge clk);

        apply_stimulus(4'b0000, 32'd5, 32'd3, 32'd8, "ADD");
        apply_stimulus(4'b1000, 32'd5, 32'd3, 32'd2, "SUB");
        apply_stimulus(4'b0001, 32'd1, 32'd3, 32'd8, "SLL");
        apply_stimulus(4'b0010, 32'd2, 32'd5, 32'd1, "SLT true"); 
        apply_stimulus(4'b0010, 32'd5, 32'd2, 32'd0, "SLT false");
        apply_stimulus(4'b0011, 32'd2, 32'd5, 32'd1, "SLTU true");
        apply_stimulus(4'b0100, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "XOR");
        apply_stimulus(4'b0101, 32'd8, 32'd2, 32'd2, "SRL");
      	apply_stimulus(4'b1001, -32'd16, 32'd2, -32'sd64, "SRA");
        apply_stimulus(4'b0110, 32'hAAAA0000, 32'h0000FFFF, 32'hAAAAFFFF, "OR");
        apply_stimulus(4'b0111, 32'hFFFF0000, 32'h00FF00FF, 32'h00FF0000, "AND");
      	apply_stimulus(4'b0000, 32'sd5, -32'd5, 32'd0, "ADD zero out");

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule