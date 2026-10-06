module mem_stage (
    // control signals
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    input  logic        stall,

    // inputs from ex/mem pipeline register
    input  logic [31:0] alu_result_in,
    input  logic [31:0] rs2_val_in,
    input  logic [4:0]  rd_addr_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  opcode_in,

    // data memory interface (to dmem.sv)
    output logic        req_valid,
    output logic        req_write,
    output logic [31:0] req_addr,
    output logic [31:0] req_wdata,
    output logic [3:0]  req_be,
    input  logic        req_ready,

    // outputs to mem/wb pipeline register
    output logic [31:0] alu_result_out,
    output logic [4:0]  rd_addr_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  opcode_out,
    output logic [1:0]  byte_offset_out
);

    logic is_load;
    logic is_store;
    logic [1:0] byte_offset;
    // FIX: Add logic to detect misaligned accesses
    logic misaligned; 

    assign is_load     = (opcode_in == 7'b0000011);
    assign is_store    = (opcode_in == 7'b0100011);
    assign byte_offset = alu_result_in[1:0];

    // FIX: Determine if the address is misaligned for halfwords (funct3_in[1:0]==01) or words (funct3_in[1:0]==10)
    assign misaligned  = (funct3_in[1:0] == 2'b01 && alu_result_in[0]) ||
                         (funct3_in[1:0] == 2'b10 && |alu_result_in[1:0]);

    // memory request mapped to dmem interface
    // FIX: Gate req_valid with !misaligned to prevent silent memory corruption
    assign req_valid   = (is_load || is_store) && !misaligned && !stall && !flush;
    assign req_write   = is_store;
    assign req_addr    = {alu_result_in[31:2], 2'b00}; // word-align the address for simple_memory

    always_comb begin
        // default assignments
        req_wdata = 32'b0;
        req_be    = 4'b0000;

        if (is_store) begin
            case (funct3_in)
                3'b000: begin // sb (store byte)
                    req_wdata = {4{rs2_val_in[7:0]}};
                    req_be    = 4'b0001 << byte_offset;
                end
                3'b001: begin // sh (store halfword)
                    req_wdata = {2{rs2_val_in[15:0]}};
                    req_be    = 4'(8'b0000_0011 << byte_offset); // prevent bit truncation on 4-bit shift
                end
                3'b010: begin // sw (store word)
                    req_wdata = rs2_val_in;
                    req_be    = 4'b1111;
                end
                default: begin
                    req_wdata = 32'b0;
                    req_be    = 4'b0000;
                end
            endcase
        end
    end

    assign alu_result_out  = alu_result_in;
    assign rd_addr_out     = rd_addr_in;
    assign funct3_out      = funct3_in;
    assign opcode_out      = opcode_in;
    assign byte_offset_out = byte_offset;

endmodule
