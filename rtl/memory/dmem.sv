module dmem (
    input  logic        clk,
    input  logic        rst,

    // CPU -> data memory
    input  logic        req_valid,
    input  logic        req_write,
    input  logic [31:0] req_addr,
    input  logic [31:0] req_wdata,
    input  logic [3:0]  req_be,

    // Data memory -> CPU
    output logic        req_ready,
    output logic        rsp_valid,
    output logic [31:0] rsp_rdata,

    // dmem -> shared memory
    output logic        mem_valid,
    output logic        mem_write,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic [3:0]  mem_be,

    // shared memory -> dmem
    input  logic        mem_ready,
    input  logic        mem_rvalid,
    input  logic [31:0] mem_rdata
);

    assign mem_valid = req_valid;
    assign mem_write = req_write;
    assign mem_addr  = req_addr;
    assign mem_wdata = req_wdata;
    assign mem_be    = req_be;

    assign req_ready = mem_ready;

    assign rsp_valid = mem_rvalid;
    assign rsp_rdata = mem_rdata;

endmodule