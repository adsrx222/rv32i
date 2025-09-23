`timescale 1 ns / 1 ps

module imem #(
    parameter int MEM_SIZE = 1024,
    parameter string INIT_FILE = "program.hex"
) (
    input logic clk,
    input logic [31:0] pc,
    output logic [31:0] instr
);

logic [31:0] mem [0:MEM_SIZE-1];

initial begin
    $readmemh(INIT_FILE, mem);
end

always_ff @ (posedge clk) begin
    instr <= mem[pc];
end

endmodule