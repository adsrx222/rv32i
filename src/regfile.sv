module regfile (
    input logic clk,
    input logic regwrite,
    input logic [31:0] instr,
    input logic [31:0] write_data,
    output logic [31:0] readout1,
    output logic [31:0] readout2
);

logic [31:0] registers [0:31];

//read_reg1 = instr[19:15];
//read_reg2 = instr[24:20];
//write_reg = instr[11:7];

initial begin
    for (int i = 0; i < 32; i++) registers[i] = 0;
end

always_ff @(posedge clk) begin
    if(regwrite)
        registers[instr[11:7]] = write_data;
    else
        readout1 = registers[instr[19:15]];
        readout2 = registers[instr[24:20]];
end

endmodule