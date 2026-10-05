module if_stage (
    input   logic       clk,
    input   logic       rst,
    input   logic       clr,

    input   logic[31:0] curr_pc,
    output  logic[31:0] next_pc,

    // branch resolve update
    input   logic       branch_resolve_taken,
    input   logic       branch_resolve_valid,
    input   logic[31:0] branch_resolve_pc,

    input   logic[31:0] branch_ghr,
    input   logic[31:0] branch_pht,
);


endmodule