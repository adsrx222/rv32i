`timescale 1 ns / 1 ps

module imem_tb;

    logic clk;
    logic [31:0] pc;
    logic [31:0] instr;

    imem #(
        .MEM_SIZE(1024),
        .INIT_FILE("program.hex")
    ) dut (
        .clk(clk),
        .pc(pc),
        .instr(instr)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    string result_msg;

    task apply_stimulus(
        input logic [31:0] test_pc,
        input logic [31:0] expected_instr
    );
        begin
            @(negedge clk);
            pc = test_pc;

            @(posedge clk);
            #10;

            if (instr === expected_instr)
                result_msg = "PASS";
            else
                result_msg = $sformatf("FAIL (exp=0x%08x, got=0x%08x)", expected_instr, instr);

            $display("PC: %0d | INSTR: 0x%08x | EXPECTED: 0x%08x | RESULT: %s", pc, instr, expected_instr, result_msg);
        end
    endtask

    initial begin
        $display("=== imem TESTBENCH ===");

        pc = 32'b0;

        #10;

        apply_stimulus(0, 32'hDEADBEEF);
        apply_stimulus(1, 32'h12345678);
        apply_stimulus(2, 32'hCAFEBABE);
        apply_stimulus(3, 32'h00000000);
        apply_stimulus(4, 32'hFFFFFFFF);
        apply_stimulus(5, 32'hAABBCCDD);
        apply_stimulus(6, 32'h11223344);
        apply_stimulus(7, 32'h55667788);
        apply_stimulus(8, 32'h99AABBCC);
        apply_stimulus(9, 32'hDDEEFF00);

        $display("=== Testbench completed ===");
        $finish;
    end

endmodule
