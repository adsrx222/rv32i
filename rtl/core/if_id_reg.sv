module if_id_reg #(
    // NOP instruction value derived from if_stage_b
    parameter logic [31:0] NOP_INST = 32'h0000_0013
) (
    // Standard control signals used across pipeline stages
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    input  logic        stall,

    // Inputs from the IF stage
    input  logic [31:0] pc_in,
    input  logic [31:0] instr_in,
    input  logic        inst_valid_in, // Added missing valid connection from if_stage_b

    // Outputs driving the ID stage inputs
    output logic [31:0] pc_out,
    output logic [31:0] instr_out,
    output logic        inst_valid_out // Forwarded valid signal for downstream stages
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out         <= 32'b0;
            instr_out      <= NOP_INST; // Reset to NOP
            inst_valid_out <= 1'b0;
            
        end else if (flush) begin
            // Inject NOP bubble into pipeline when branch/flush occurs
            pc_out         <= 32'b0;
            instr_out      <= NOP_INST;
            inst_valid_out <= 1'b0; // Force valid to 0 during flush
            
        end else if (stall) begin
            // Hold current instruction, pc, and valid status during a stall
            pc_out         <= pc_out;
            instr_out      <= instr_out;
            inst_valid_out <= inst_valid_out;
            
        end else begin
            // Pass values forward to ID stage
            pc_out         <= pc_in;
            instr_out      <= instr_in;
            inst_valid_out <= inst_valid_in;
        end
    end

endmodule
