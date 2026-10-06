module ex_mem_reg (
    // Standard control signals used across pipeline stages
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    input  logic        stall,

    // Inputs from the EX stage logic
    input  logic [31:0] pc_in,
    input  logic [31:0] alu_result_in,
    input  logic [31:0] rs2_val_in,
    input  logic [4:0]  rd_addr_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  opcode_in,

    // Outputs driving the MEM stage logic
    output logic [31:0] pc_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] rs2_val_out,
    output logic [4:0]  rd_addr_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  opcode_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out         <= 32'b0;
            alu_result_out <= 32'b0;
            rs2_val_out    <= 32'b0;
            rd_addr_out    <= 5'b0;
            funct3_out     <= 3'b0;
            opcode_out     <= 7'b0010011; // NOP opcode

        end else if (flush) begin
            // Inject NOP bubble into pipeline when branch/flush occurs
            pc_out         <= 32'b0;
            alu_result_out <= 32'b0;
            rs2_val_out    <= 32'b0;
            rd_addr_out    <= 5'b0;
            funct3_out     <= 3'b0;
            opcode_out     <= 7'b0010011;

        end else if (stall) begin
            // Hold current register values on stall
            pc_out         <= pc_out;
            alu_result_out <= alu_result_out;
            rs2_val_out    <= rs2_val_out;
            rd_addr_out    <= rd_addr_out;
            funct3_out     <= funct3_out;
            opcode_out     <= opcode_out;

        end else begin
            // Pass forward values to MEM stage
            pc_out         <= pc_in;
            alu_result_out <= alu_result_in;
            rs2_val_out    <= rs2_val_in;
            rd_addr_out    <= rd_addr_in;
            funct3_out     <= funct3_in;
            opcode_out     <= opcode_in;
        end
    end

endmodule
