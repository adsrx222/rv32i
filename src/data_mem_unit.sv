`timescale 1 ns / 1 ps

module data_mem_unit # (
    parameter int DMEM_SIZE = 1024
) (
    input clk,
    input memwrite,
    input memread,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);

logic [31:0] data_mem [0:DMEM_SIZE-1];

initial begin
    integer i;
    for (i = 0; i < DMEM_SIZE; i = i + 1) begin
        data_mem[i] = 32'b0;
    end
end

always_ff @(posedge clk) begin
    if (memwrite) begin
        if (addr < DMEM_SIZE)
            data_mem[addr] = write_data;
    end
end

always_ff @(posedge clk) begin
    if (memread) begin
        if (addr < DMEM_SIZE)
            read_data = data_mem[addr];
        else
            read_data = 32'b0;
    end
end

endmodule