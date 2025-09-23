`timescale 1 ns / 1 ps

module data_mem_mux (
    input logic clk,
    input logic memtoreg,
    input logic [31:0] read_data,
    input logic [31:0] alu_result,
    output logic [31:0] write_data
);

always_ff @(posedge clk) begin
    if(memtoreg)
        write_data = read_data;
    else
        write_data = alu_result;
end

endmodule