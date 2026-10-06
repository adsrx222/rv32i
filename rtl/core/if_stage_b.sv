module if_stage_b # (
    parameter logic [31:0] NOP_INST = 32'h0000_0013
) (
    // control signals
    input   logic           clk,
    input   logic           rst_n,
    input   logic           flush,
    input   logic           stall,

    // core i/o
    input   logic[31:0]     pc,
    output  logic           inst_valid,
    output  logic [31:0]    inst,
    output  logic [31:0]    inst_pc,      // Retained from fix 2: aligned PC

    // memory request signals
    output  logic           req_valid,
    output  logic [31:0]    req_addr,

    // memory response signals
    input   logic           rsp_ready,
    input   logic           rsp_valid,
    input   logic [31:0]    rsp_rdata
);

    logic [31:0] req_pc_q; // Retained from fix 2: tracks requested PC
    
    // FIX: Add skid buffer registers to catch memory responses during a stall
    logic [31:0] skid_inst, skid_pc; 
    logic        skid_valid;

    // FIX: Skid buffer control logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            skid_valid <= 1'b0;
        end else if (stall && rsp_valid && rsp_ready) begin
            skid_valid <= 1'b1; 
            skid_inst  <= rsp_rdata; 
            skid_pc    <= req_pc_q;
        end else if (!stall) begin
            skid_valid <= 1'b0;
        end
    end

    // Retained from fix 2: capture the PC of the request issued last cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            req_pc_q <= '0; 
        else if (!stall)
            req_pc_q <= pc;   
    end

    assign req_addr  = pc;
    // FIX: Added !flush to prevent the memory from accepting a request for the wrong-path PC during a branch flush
    assign req_valid = rst_n && !stall && !flush; 

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            inst       <= NOP_INST;
            inst_valid <= 1'b0;
            inst_pc    <= '0;
        end else if (flush) begin
            // inject NOP bubble into pipeline when branch/flush occurs
            inst       <= NOP_INST;
            inst_valid <= 1'b0;
            inst_pc    <= '0;
        end else if (stall) begin
            // hold current instruction and valid status during a stall
            inst       <= inst;
            inst_valid <= inst_valid;
            inst_pc    <= inst_pc;
        end else begin
            // FIX: Prioritize skid buffer data when coming out of a stall
            if (skid_valid) begin 
                inst       <= skid_inst; 
                inst_pc    <= skid_pc; 
                inst_valid <= 1'b1; 
            end else if (rsp_valid && rsp_ready) begin
                inst       <= rsp_rdata;
                inst_valid <= 1'b1;
                inst_pc    <= req_pc_q; // Retained from fix 2: assign synchronized PC
            end else begin
                inst       <= NOP_INST;
                inst_valid <= 1'b0;
                inst_pc    <= '0;
            end
        end
    end

endmodule
