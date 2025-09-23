`timescale 1 ns / 1 ps

module branch_control (
    input logic clk,
    input logic branch,
    input logic zero,
    input logic [1:0] aluop,
    input logic [31:0] alu_result,
    input logic [31:0] instr,
    output logic branch_logic
);

always_ff @(posedge clk) begin
    if(branch) begin
        case (instr[14:12])
    		3'd0: branch_logic <= zero ? 1 : 0;         // BEQ
    		3'd1: branch_logic <= zero ? 0 : 1;         // BNE
    		3'd4: branch_logic <= (alu_result == 1);    // BLT
    		3'd5: branch_logic <= (alu_result == 0);    // BGE
    		3'd6: branch_logic <= (alu_result == 1);    // BLTU
    		3'd7: branch_logic <= (alu_result == 0);    // BGEU
    		default: branch_logic <= 0;
		endcase
    end else begin
        branch_logic <= 0;
    end
end

endmodule
