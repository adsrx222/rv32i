`timescale 1 ns / 1 ps

module pc_next_instruction (
    input logic clk,
    input logic branch,
    input logic zero,
    input logic [31:0] pc,
    input logic [63:0] imm,
    output logic [31:0] pc_next
);

logic [31:0] pc_add_four = pc + 4;

logic [63:0] imm_add_shifted = pc + (imm << 1);

always_ff @ (posedge clk) begin
    if(branch)
        pc_next = imm_add_shifted;
    else
        pc_next = pc_add_four;
end

endmodule