`timescale 1ns / 1ps

module imm_gen_tb;

    logic clk;
    logic [31:0] instr;
    
    logic [63:0] imm_extended;

    logic [31:0] beq_instr;
    logic [31:0] jal_instr;

    imm_gen dut (
        .clk(clk),
        .instr(instr),
        .imm_extended(imm_extended)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task apply_stimulus (
        input logic [31:0] instruction,
        input string test_name,
        input logic [63:0] expected_imm_extended
    );
        string result_msg;
        begin
            @(negedge clk);
            instr = instruction;

            @(posedge clk);
            #1;

            if (imm_extended === expected_imm_extended)
                result_msg = "PASS";
            else
                result_msg = $sformatf("FAIL (exp=0x%d)", expected_imm_extended);

            $display("%-25s | %d | %b | 0x%h | %-15s", 
                     test_name, instruction, imm_extended, imm_extended, result_msg);
        end
    endtask

    initial begin
        $display("=== imm_gen TESTBENCH (instr, imm_extended (binary), imm_extended (hex), result_msg) ===");

        instr = 32'b0;
        repeat (2) @(posedge clk);

        // ------------------------------
        // I-TYPE: ADDI x1, x2, 0x10
        // imm[11:0]=0x10
        apply_stimulus(32'b00000001000000010000000010010011, "ADDI (I-type)", 64'h0000000000000010);

        // ------------------------------
        // S-TYPE: SW x3, 0x10(x2)
        // imm = 0x10 → imm[11:5]=0000000, imm[4:0]=10000
        apply_stimulus(32'b00000000001100010010100000100011, "SW (S-type)", 64'h0000000000000010);

        // ------------------------------
        // U-TYPE: LUI x1, 0x10000 → imm = 0x10000
        apply_stimulus(32'b00010000000000000000000010110111, "LUI (U-type)", 64'h0000000000010000);

        // ------------------------------
        // B-TYPE: BEQ x1, x2, offset = 0x10
        // imm[12|10:5|4:1|11] = {0,000001,0000,0} = 0x10
        beq_instr = {
            1'b0,          // imm[12]
            6'b000001,     // imm[10:5]
            5'b00010,      // rs2 = x2
            5'b00001,      // rs1 = x1
            3'b000,        // funct3
            4'b0000,       // imm[4:1]
            1'b0,          // imm[11]
            7'b1100011     // opcode
        };
        apply_stimulus(beq_instr, "BEQ (B-type)", 64'h0000000000000010);

        // ------------------------------
        // J-TYPE: JAL x1, offset = 0x20
        // imm[20|10:1|11|19:12] = {0,0000010000,0,00000000}
        jal_instr = {
            1'b0,           // imm[20]
            8'b00000000,    // imm[19:12]
            1'b0,           // imm[11]
            10'b0000010000, // imm[10:1]
            5'b00001,       // rd = x1
            7'b1101111      // opcode
        };
        apply_stimulus(jal_instr, "JAL (J-type)", 64'h0000000000000020);

        // ------------------------------
        // R-TYPE: ADD x1, x2, x3 → should produce 0 immediate
        apply_stimulus(32'b00000000001100010000000010110011, "ADD (R-type)", 64'h0000000000000000);

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule
