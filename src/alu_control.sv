`timescale 1ns / 1ps

module alu_control # (
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
    input logic [1:0] alu_cop,
    input logic [31:0] instr,
    output logic [3:0] aluop
);

//funct3 = instr[14:12];
//funct7 = instr[31:25];

always_ff @ (posedge clk) begin
    case (alu_cop)
        
        2'b00: begin
            aluop = ADD;
        end

        2'b01: begin
            case (instr[14:12])
                0: aluop = SUB;
                1: aluop = SUB;
                4: aluop = SLT;
                5: aluop = SLT;
                6: aluop = SLTU;
                7: aluop  = SLTU;
            endcase
        end

        2'b10: begin
            case (instr[14:12])
                0: if(instr[31:25]==0) begin aluop = ADD; end else begin aluop = SUB; end
                1: aluop = SLL;
                2: aluop = SLT;
                3: aluop = SLTU;
                4: aluop = XOR;
                5: if(instr[31:25]==0) begin aluop = SRL; end else begin aluop = SRA; end
                6: aluop = OR;
                7: aluop = AND;
            endcase
        end
    endcase
end

endmodule
