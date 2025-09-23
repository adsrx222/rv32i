`timescale 1ns / 1ps

module alu_control_tb;

    logic clk;
    logic [1:0] alu_cop;
    logic [31:0] instr;
    
    logic [3:0] aluop;

    alu_control dut (
        .clk(clk),
        .alu_cop(alu_cop),
        .instr(instr),
        .aluop(aluop)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task apply_stimulus (
        input logic [1:0] cop,
        input logic [2:0] f3,
        input logic [6:0] f7,
        input string test_name,
        input logic [3:0] expected_aluop
    );

    string result_msg;

    begin
        @(negedge clk);
        alu_cop = cop;
        instr = 32'b0;
        instr[14:12] = f3;
        instr[31:25] = f7;

        @(posedge clk);
        #5;

        if (aluop === expected_aluop)
            result_msg = "PASS";
        else
            result_msg = $sformatf("FAIL (exp=0x%0h)", expected_aluop);

        $display("%-25s | %3b | 0x%1h  | 0x%02h  | 0x%0h   | %-15s", test_name, cop, f3, f7, aluop, result_msg);
    end
        
    endtask

    initial begin
        $display("=== alu_control TESTBENCH (cop, f3, f7, aluop, result_msg) ===");

        alu_cop = 0;
        instr = 0;

        //Wait 2 cycles for the DUT to initialize
        repeat (2) @(posedge clk);

        //IL TYPE
        apply_stimulus(2'b00, 3'd0, 7'd0, "ALU_OP=00 => ADD", 4'b0000);

        //B Type
        apply_stimulus(2'b01, 3'd0, 7'd0, "BEQ -> SUB", 4'b1000);
        apply_stimulus(2'b01, 3'd4, 7'd0, "BLT -> SLT", 4'b0010);
        apply_stimulus(2'b01, 3'd6, 7'd0, "BLTU -> SLTU", 4'b0011);

        //R TYPE || I TYPE
        apply_stimulus(2'b10, 3'd0, 7'b0000000, "ADD (funct7=0)", 4'b0000);
        apply_stimulus(2'b10, 3'd0, 7'b0100000, "SUB (funct7=0x20)", 4'b1000);
        apply_stimulus(2'b10, 3'd1, 7'd0, "SLL", 4'b0001);
        apply_stimulus(2'b10, 3'd2, 7'd0, "SLT", 4'b0010);
        apply_stimulus(2'b10, 3'd3, 7'd0, "SLTU", 4'b0011);
        apply_stimulus(2'b10, 3'd4, 7'd0, "XOR", 4'b0100);
        apply_stimulus(2'b10, 3'd5, 7'b0000000, "SRL (funct7=0)", 4'b0101);
        apply_stimulus(2'b10, 3'd5, 7'b0100000, "SRA (funct7=0x20)", 4'b1001);
        apply_stimulus(2'b10, 3'd6, 7'd0, "OR", 4'b0110);
        apply_stimulus(2'b10, 3'd7, 7'd0, "AND", 4'b0111);

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule