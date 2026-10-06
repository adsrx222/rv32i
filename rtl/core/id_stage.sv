module id_stage (
    // control signals
    input  logic        clk,     // Unused after fix
    input  logic        rst_n,   // Unused after fix
    input  logic        flush,   // Unused after fix
    input  logic        stall,   // Unused after fix

    // Inputs from IF/ID Register
    input  logic [31:0] pc_in,
    input  logic [31:0] instr_in,
    input  logic        inst_valid_in, // Receives the new valid signal from IF/ID

    // regfile i/o
    output logic [4:0]  rs1_addr,
    output logic [4:0]  rs2_addr,
    input  logic [31:0] rs1_rsp,
    input  logic [31:0] rs2_rsp,

    // extracted instruction field output
    output logic [31:0] pc_out,
    output logic [31:0] rs1_val_out,
    output logic [31:0] rs2_val_out,
    output logic [31:0] imm_out,
    output logic [4:0]  rd_addr_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  funct7_out,
    output logic [6:0]  opcode_out,
    output logic        inst_valid_out // Propagates valid signal to EX stage / stall controller
);

    logic [6:0] opcode_comb;
    logic [4:0] rd_addr_comb;
    logic [2:0] funct3_comb;
    logic [6:0] funct7_comb;

    assign opcode_comb  = instr_in[6:0];
    assign rd_addr_comb = instr_in[11:7];
    assign funct3_comb  = instr_in[14:12];
    assign funct7_comb  = instr_in[31:25];

    // wire inputs to regfile
    assign rs1_addr = instr_in[19:15];
    assign rs2_addr = instr_in[24:20];

    logic [31:0] imm_comb;
    always_comb begin
        case (opcode_comb)
            // i-type
            7'b0000011, 7'b0010011, 7'b1100111: begin
                imm_comb = {{20{instr_in[31]}}, instr_in[31:20]};
            end
            // s-type
            7'b0100011: begin
                imm_comb = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
            end
            // b-type
            7'b1100011: begin
                imm_comb = {{19{instr_in[31]}}, instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
            end
            // u-type
            7'b0110111, 7'b0010111: begin
                imm_comb = {instr_in[31:12], 12'b0};
            end
            // j-type
            7'b1101111: begin
                imm_comb = {{11{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
            end
            default: begin
                // r-type
                imm_comb = 32'h0000_0000;
            end
        endcase
    end

    // FIX: Removed duplicated always_ff block. Stage is now purely combinational.
    assign pc_out         = pc_in;
    assign rs1_val_out    = rs1_rsp;
    assign rs2_val_out    = rs2_rsp;
    assign imm_out        = imm_comb;
    assign rd_addr_out    = rd_addr_comb;
    assign funct3_out     = funct3_comb;
    assign funct7_out     = funct7_comb;
    assign opcode_out     = opcode_comb;
    assign inst_valid_out = inst_valid_in;

endmodule
