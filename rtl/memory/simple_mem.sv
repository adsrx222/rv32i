module simple_memory #(
    parameter int MEM_BYTES = 64 * 1024
) (
    input logic clk,
    input logic rst,

    // ------------------------------------------------------------
    // Instruction memory port
    // ------------------------------------------------------------

    input  logic        imem_valid,
    input  logic [31:0] imem_addr,

    output logic        imem_ready,
    output logic        imem_rvalid,
    output logic [31:0] imem_rdata,

    // ------------------------------------------------------------
    // Data memory port
    // ------------------------------------------------------------

    input  logic        dmem_valid,
    input  logic        dmem_write,
    input  logic [31:0] dmem_addr,
    input  logic [31:0] dmem_wdata,
    input  logic [3:0]  dmem_be,

    output logic        dmem_ready,
    output logic        dmem_rvalid,
    output logic [31:0] dmem_rdata
);

    localparam int NUM_WORDS = MEM_BYTES / 4;
    // FIX: Calculate exact index width and slice address bits to keep index in bounds
    localparam int AW        = $clog2(NUM_WORDS);

    logic [AW-1:0] iaddr;
    logic [AW-1:0] daddr;

    assign iaddr = imem_addr[AW+1:2];
    assign daddr = dmem_addr[AW+1:2];

    logic [31:0] memory [0:NUM_WORDS-1];

    // Memory is always ready in this simple implementation
    assign imem_ready = 1'b1;
    assign dmem_ready = 1'b1;

    always_ff @(posedge clk) begin
        if (rst) begin
            imem_rvalid <= 1'b0;
            imem_rdata  <= 32'b0;
        end
        else begin
            imem_rvalid <= 1'b0;

            if (imem_valid && imem_ready) begin
                // FIX: Use bounded iaddr index instead of unbounded 32-bit shift
                imem_rdata  <= memory[iaddr];
                imem_rvalid <= 1'b1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            dmem_rvalid <= 1'b0;
            dmem_rdata  <= 32'b0;
        end
        else begin
            dmem_rvalid <= 1'b0;

            if (dmem_valid && dmem_ready) begin

                if (dmem_write) begin

                    // FIX: Use bounded daddr index for byte-enabled writes
                    if (dmem_be[0])
                        memory[daddr][7:0]
                            <= dmem_wdata[7:0];

                    if (dmem_be[1])
                        memory[daddr][15:8]
                            <= dmem_wdata[15:8];

                    if (dmem_be[2])
                        memory[daddr][23:16]
                            <= dmem_wdata[23:16];

                    if (dmem_be[3])
                        memory[daddr][31:24]
                            <= dmem_wdata[31:24];

                end
                else begin

                    // FIX: Use bounded daddr index for reads
                    dmem_rdata  <= memory[daddr];
                    dmem_rvalid <= 1'b1;

                end
            end
        end
    end

endmodule
