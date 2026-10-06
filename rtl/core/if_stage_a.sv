module if_stage_a # (
    parameter logic [31:0] RESET_PC = 32'h0000_0000
) (
    // control signals
    input   logic       clk,
    input   logic       rst_n,
    input   logic       flush,
    input   logic       stall,

    input   logic[31:0] curr_pc,
    output  logic[31:0] next_pc,

    // branch resolve update
    //input   logic       branch_resolve_taken,
    //input   logic       branch_resolve_valid,
    input   logic[31:0] branch_resolve_pc

    //input   logic[31:0] branch_ghr,
    //input   logic[31:0] branch_pht
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            next_pc <= RESET_PC;
        // FIX: Swapped stall and flush priority. Flush now has priority to prevent losing branch redirects.
        end else if (flush) begin
            next_pc <= branch_resolve_pc;   // redirect PC on branch resolution / misprediction
        end else if (stall) begin
            next_pc <= curr_pc;             // maintain current PC on pipeline stall
        end else begin
            next_pc <= curr_pc + 32'd4;     // always assume NT
        end
    end

endmodule
