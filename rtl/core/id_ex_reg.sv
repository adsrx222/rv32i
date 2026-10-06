module id_ex_reg (
    // Standard control signals
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    input  logic        stall,

    // Inputs from the ID stage
    input  logic [31:0] pc_in,
    input  logic [31:0] rs1_val_in,
    input  logic [31:0] rs2_val_in,
    input  logic [31:0] imm_in,
    input  logic [4:0]  rd_addr_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  funct7_in,
    input  logic [6:0]  opcode_in,

    // Outputs driving the EX stage
    output logic [31:0] pc_out,
    output logic [31:0] rs1_val_out,
    output logic [31:0] rs2_val_out,
    output logic [31:0] imm_out,
    output logic [4:0]  rd_addr_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  funct7_out,
    output logic [6:0]  opcode_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out      <= 32'b0;
            rs1_val_out <= 32'b0;
            rs2_val_out <= 32'b0;
            imm_out     <= 32'b0;
            rd_addr_out <= 5'b0;
            funct3_out  <= 3'b0;
            funct7_out  <= 7'b0;
            opcode_out  <= 7'b0010011; // NOP opcode[cite: 24, 26]

        end else if (flush) begin
            // Inject NOP bubble into pipeline when branch/flush occurs[cite: 24, 26]
            pc_out      <= 32'b0;
            rs1_val_out <= 32'b0;
            rs2_val_out <= 32'b0;
            imm_out     <= 32'b0;
            rd_addr_out <= 5'b0;
            funct3_out  <= 3'b0;
            funct7_out  <= 7'b0;
            opcode_out  <= 7'b0010011;

        end else if (stall) begin
            // Hold current register values on stall
            pc_out      <= pc_out;
            rs1_val_out <= rs1_val_out;
            rs2_val_out <= rs2_val_out;
            imm_out     <= imm_out;
            rd_addr_out <= rd_addr_out;
            funct3_out  <= funct3_out;
            funct7_out  <= funct7_out;
            opcode_out  <= opcode_out;

        end else begin
            // Pass forward values to EX stage
            pc_out      <= pc_in;
            rs1_val_out <= rs1_val_in;
            rs2_val_out <= rs2_val_in;
            imm_out     <= imm_in;
            rd_addr_out <= rd_addr_in;
            funct3_out  <= funct3_in;
            funct7_out  <= funct7_in;
            opcode_out  <= opcode_in;
        end
    end

endmodule
