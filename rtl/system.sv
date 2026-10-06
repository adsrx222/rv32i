`include "core.sv"
`include "simple_mem.sv"

module riscv_system_top (
    input  logic clk,
    input  logic rst_n
);

    // =========================================================================
    // Instruction Memory Interconnect
    // =========================================================================
    logic        imem_valid;
    logic [31:0] imem_addr;
    logic        imem_ready;
    logic        imem_rvalid;
    logic [31:0] imem_rdata;

    // =========================================================================
    // Data Memory Interconnect
    // =========================================================================
    logic        dmem_valid;
    logic        dmem_write;
    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic [3:0]  dmem_be;
    logic        dmem_ready;
    logic        dmem_rvalid;
    logic [31:0] dmem_rdata;

    // =========================================================================
    // RISC-V Core Instantiation
    // =========================================================================
    core core_inst (
        .clk             (clk),
        .rst_n           (rst_n),

        .imem_req_valid  (imem_valid),
        .imem_req_addr   (imem_addr),
        .imem_rsp_ready  (imem_ready),
        .imem_rsp_valid  (imem_rvalid),
        .imem_rsp_rdata  (imem_rdata),

        .dmem_req_valid  (dmem_valid),
        .dmem_req_write  (dmem_write),
        .dmem_req_addr   (dmem_addr),
        .dmem_req_wdata  (dmem_wdata),
        .dmem_req_be     (dmem_be),
        .dmem_req_ready  (dmem_ready),
        .dmem_rsp_valid  (dmem_rvalid),
        .dmem_rsp_rdata  (dmem_rdata)
    );

    // =========================================================================
    // Simple Memory Instantiation
    // =========================================================================
    simple_memory #(
        .MEM_BYTES(64 * 1024)
    ) memory_inst (
        .clk         (clk),
        .rst         (~rst_n), 

        .imem_valid  (imem_valid),
        .imem_addr   (imem_addr),
        .imem_ready  (imem_ready),
        .imem_rvalid (imem_rvalid),
        .imem_rdata  (imem_rdata),

        .dmem_valid  (dmem_valid),
        .dmem_write  (dmem_write),
        .dmem_addr   (dmem_addr),
        .dmem_wdata  (dmem_wdata),
        .dmem_be     (dmem_be),
        .dmem_ready  (dmem_ready),
        .dmem_rvalid (dmem_rvalid),
        .dmem_rdata  (dmem_rdata)
    );

endmodule
