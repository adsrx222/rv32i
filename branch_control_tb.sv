`timescale 1 ns / 1 ps

module branch_control_tb;

    logic clk;
    logic branch;
    logic zero;
    logic [1:0] aluop;
    logic [31:0] alu_result;
    logic [31:0] instr;

    logic branch_logic;

    branch_control dut (
        .clk(clk),
        .branch(branch),
        .zero(zero),
        .aluop(aluop),
        .alu_result(alu_result),
        .instr(instr),
        .branch_logic(branch_logic)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task apply_stimulus(
        input logic b,
        input logic z,
        input logic [1:0] op,
        input logic [2:0] f3,
        input logic [31:0] result,
        input string test_name
    );
        begin
          	@(negedge clk);
            branch = b;
            zero = z;
            aluop = op;
            alu_result = result;

            // input funct3, to determine branch type
            instr = 32'b0;
            instr[14:12] = f3;

            @(posedge clk);
            #5;

            $display("[%s] -> branch=%0b zero=%0b funct3=%0d alu_result=%0d => branch_logic=%0b",
                     test_name, branch, zero, f3, alu_result, branch_logic);
        end
    endtask

    initial begin
      	$display("=== branch_control TESTBENCH ===");

        branch = 0;
        zero = 0;
        aluop = 0;
        alu_result = 0;
        instr = 0;

        repeat (2) @(posedge clk);

        // Test funct3 = 0 (BEQ): branch if zero == 1
        apply_stimulus(1, 1, 2'b00, 3'd0, 32'd0, "BEQ zero=1");
        apply_stimulus(1, 0, 2'b00, 3'd0, 32'd0, "BEQ zero=0");

        // Test funct3 = 1 (BNE): branch if zero == 0
        apply_stimulus(1, 0, 2'b00, 3'd1, 32'd0, "BNE zero=0");
        apply_stimulus(1, 1, 2'b00, 3'd1, 32'd0, "BNE zero=1");

        // Test funct3 = 4 (BLT): branch if alu_result == 1
      	apply_stimulus(1, 0, 2'b00, 3'd4, 32'd1, "BLT alu_result=1");
        apply_stimulus(1, 0, 2'b00, 3'd4, 32'd0, "BLT alu_result=0");

        // Test funct3 = 5 (BGE): branch if alu_result == 0
        apply_stimulus(1, 0, 2'b00, 3'd5, 32'd0, "BGE alu_result=0");
        apply_stimulus(1, 0, 2'b00, 3'd5, 32'd1, "BGE alu_result=1");

        // Test funct3 = 6 (BLTU): branch if alu_result == 1
        apply_stimulus(1, 0, 2'b00, 3'd6, 32'd1, "BLTU alu_result=1");
        apply_stimulus(1, 0, 2'b00, 3'd6, 32'd0, "BLTU alu_result=0");

        // Test funct3 = 7 (BGEU): branch if alu_result == 0
        apply_stimulus(1, 0, 2'b00, 3'd7, 32'd0, "BGEU alu_result=0");
        apply_stimulus(1, 0, 2'b00, 3'd7, 32'd1, "BGEU alu_result=1");

        // Test branch = 0 (should disable branching regardless of other signals)
        apply_stimulus(0, 1, 2'b00, 3'd0, 32'd0, "Branch disabled");

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule