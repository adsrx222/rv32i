`timescale 1 ns / 1 ps

module imm_gen # (
    parameter RTYPE = 7'b0110011,
    parameter IMTYPE = 7'b0010011,
    parameter ILTYPE = 7'b0000011,
    parameter STYPE = 7'b0100011,
    parameter BTYPE = 7'b1100011,
    parameter UTYPE = 7'b0110111,
    parameter JTYPE = 7'b1101111
) (
    input  logic clk,
    input  logic [31:0] instr,
    output logic [63:0] imm_extended 
);

always_ff @ (posedge clk) begin
    case(instr[6:0])
        RTYPE: imm_extended = 64'b0;

        IMTYPE, ILTYPE: // I-type
            imm_extended = { {52{instr[31]}}, instr[31:20] };

        STYPE: // S-type: imm = {instr[31:25], instr[11:7]}
            imm_extended = { {52{instr[31]}}, instr[31:25], instr[11:7] };

        BTYPE: // B-type: imm = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
            imm_extended = { {51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

        UTYPE: // U-type: imm = {instr[31:12], 12'b0}
            imm_extended = { {43{instr[31]}}, instr[31:12]};

        JTYPE: // J-type: imm = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}
            imm_extended = {{{43{instr[31]}}},({instr[31], instr[19:12], instr[20], instr[30:21]} << 1)};

        default: imm_extended = 64'b0;
    endcase
end

endmodule
