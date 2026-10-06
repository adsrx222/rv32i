module mem_wb_reg (
    // Standard control signals used across pipeline stages
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    input  logic        stall,

    // Inputs from the MEM stage logic
    input  logic [31:0] alu_result_in,
    input  logic [4:0]  rd_addr_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  opcode_in,
    input  logic [1:0]  byte_offset_in,

    // Outputs driving the WB stage logic
    output logic [31:0] alu_result_out,
    output logic [4:0]  rd_addr_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  opcode_out,
    output logic [1:0]  byte_offset_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out  <= 32'b0;
            rd_addr_out     <= 5'b0;
            funct3_out      <= 3'b0;
            opcode_out      <= 7'b0010011; // NOP opcode
            byte_offset_out <= 2'b0;

        end else if (flush) begin
            // Inject NOP bubble into pipeline when branch/flush occurs
            alu_result_out  <= 32'b0;
            rd_addr_out     <= 5'b0;
            funct3_out      <= 3'b0;
            opcode_out      <= 7'b0010011;
            byte_offset_out <= 2'b0;

        end else if (stall) begin
            // Hold current register values on stall
            alu_result_out  <= alu_result_out;
            rd_addr_out     <= rd_addr_out;
            funct3_out      <= funct3_out;
            opcode_out      <= opcode_out;
            byte_offset_out <= byte_offset_out;

        end else begin
            // Pass forward values to WB stage
            alu_result_out  <= alu_result_in;
            rd_addr_out     <= rd_addr_in;
            funct3_out      <= funct3_in;
            opcode_out      <= opcode_in;
            byte_offset_out <= byte_offset_in;
        end
    end

endmodule
