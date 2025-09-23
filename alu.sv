`timescale 1ns / 1ps

module alu # (
    ADD = 4'b0000,
    SLL = 4'b0001,
    SLT = 4'b0010,
    SLTU = 4'b0011,
    XOR = 4'b0100,
    SRL = 4'b0101,
    OR = 4'b0110,
    AND = 4'b0111,
    SUB = 4'b1000,
    SRA = 4'b1001
) (
    input logic clk,
    input logic [3:0] aluop,
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    output logic zero,
    output logic [31:0] out
);

always_ff @(posedge clk) begin
    case (aluop)
        ADD: out = rs1 + rs2;
        SLL: out = rs1 << rs2;
        SLT: out = (rs1 < rs2) ? 1 : 0;
        SLTU: out = ($unsigned(rs1) < $unsigned(rs2)) ? 1 : 0;
        XOR: out = rs1 ^ rs2;
        SRL: out = rs1 >> rs2;
        OR: out = rs1 | rs2;
        AND: out = rs1 & rs2;
        SUB: out = rs1 - rs2;
        SRA: out = rs1 <<< rs2;
        default: out = 32'b0;
    endcase
    
    zero <= (out == 32'b0) ? 1'b1 : 1'b0;
end

endmodule