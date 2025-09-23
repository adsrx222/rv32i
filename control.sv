`timescale 1ns/1ps

module control # (
    RTYPE = 7'b0110011,
    IMTYPE = 7'b0010011,
    ILTYPE = 7'b0000011,
    STYPE = 7'b0100011,
    BTYPE = 7'b1100011,
    UTYPE = 7'b0110111,
    JTYPE = 7'b1101111
) (
    input clk,
    input logic [31:0] instr,
    output logic branch,
    output logic memread,
    output logic memtoreg,
    output logic [1:0] alu_cop,
    output logic memwrite,
    output logic alusrc,
    output logic regwrite
);

always @(posedge clk) begin
	case(instr[6:0])
        RTYPE: begin
            alusrc = 1'b0;
            memtoreg = 1'b0;
            regwrite = 1'b1;
            memread = 1'b0;
            memwrite = 1'b0;
            branch = 1'b0;
            alu_cop = 2'b10;
        end
        IMTYPE: begin
            alusrc = 1'b1;
            memtoreg = 1'b0;
            regwrite = 1'b1;
            memread = 1'b0;
            memwrite = 1'b0;
            branch = 1'b0;
            alu_cop = 2'b10;
        end
        ILTYPE: begin
            alusrc = 1'b1;
            memtoreg = 1'b1;
            regwrite = 1'b1;
            memread = 1'b1;
            memwrite = 1'b0;
            branch = 1'b0;
            alu_cop = 2'b00;
        end
        STYPE: begin
            alusrc = 1'b1;
            memtoreg = 1'b0;
            regwrite = 1'b0;
            memread = 1'b0;
            memwrite = 1'b1;
            branch = 1'b0;
            alu_cop = 2'b00;
        end
        BTYPE: begin
            alusrc = 1'b1;
            memtoreg = 1'b0;
            regwrite = 1'b0;
            memread = 1'b0;
            memwrite = 1'b0;
            branch = 1'b1;
            alu_cop = 2'b01;
        end
        UTYPE: begin
            alusrc = 1'b1;
            memtoreg = 1'b1;
            regwrite = 1'b1;
            memread = 1'b0;
            memwrite = 1'b0;
            branch = 1'b0;
            alu_cop = 2'b00;
        end
        JTYPE: begin
            alusrc = 1'b1;
            memtoreg = 1'b1;
            regwrite = 1'b1;
            memread = 1'b0;
            memwrite = 1'b0;
            branch = 1'b0;
            alu_cop = 2'b00;
        end
    endcase
end

endmodule