module imem (
    input  logic        clk,
    input  logic        rst,

    // CPU -> instruction memory
    input  logic        req_valid,
    input  logic [31:0] req_addr,

    // Instruction memory -> CPU
    output logic        req_ready,
    output logic        rsp_valid,
    output logic [31:0] rsp_rdata,

    // imem -> shared memory
    output logic        mem_valid,
    output logic [31:0] mem_addr,

    // shared memory -> imem
    input  logic        mem_ready,
    input  logic        mem_rvalid,
    input  logic [31:0] mem_rdata
);

    assign mem_valid = req_valid;
    assign mem_addr  = req_addr;

    assign req_ready = mem_ready;

    assign rsp_valid = mem_rvalid;
    assign rsp_rdata = mem_rdata;

endmodule