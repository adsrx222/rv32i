module wb_stage (
    // control signals
    input  logic        clk,
    input  logic        rst_n,
    input  logic        flush,
    input  logic        stall,

    // inputs from mem/wb pipeline register
    input  logic [31:0] alu_result_in,
    input  logic [4:0]  rd_addr_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  opcode_in,
    input  logic [1:0]  byte_offset_in,

    // data memory response interface
    input  logic        rsp_valid,
    input  logic [31:0] rsp_rdata,

    // outputs to regfile / forwarding paths
    output logic        reg_write_en,
    output logic [4:0]  rd_addr_out,
    output logic [31:0] rd_data_out,

    // pipeline hazard control
    output logic        wb_stall_req
);

    logic is_load;
    assign is_load = (opcode_in == 7'b0000011);

    // stall pipeline if a load instruction is waiting on dmem
    assign wb_stall_req = is_load && !rsp_valid;

    // enable regfile write
    logic reg_write_en_comb;
    always_comb begin
        case (opcode_in)
            7'b0110011, // r-type arithmetic
            7'b0010011, // i-type arithmetic
            7'b0000011, // i-type load
            7'b0110111, // u-type lui
            7'b0010111, // u-type auipc
            7'b1101111, // j-type jal
            7'b1100111: // i-type jalr
                reg_write_en_comb = 1'b1;
            default:
                reg_write_en_comb = 1'b0;
        endcase
    end

    assign reg_write_en = reg_write_en_comb && !wb_stall_req && !flush;

    // pass destination address to the regfile
    assign rd_addr_out  = rd_addr_in;

    logic [4:0]  shift_amt;
    logic [31:0] shifted_rdata;
    logic [31:0] formatted_load_data;

    // shift the word down so the target bytes start at bit 0
    assign shift_amt     = {byte_offset_in, 3'b000}; 
    assign shifted_rdata = rsp_rdata >> shift_amt;

    always_comb begin
        case (funct3_in)
            3'b000:  formatted_load_data = {{24{shifted_rdata[7]}}, shifted_rdata[7:0]};   // lb (sign-extend)
            3'b001:  formatted_load_data = {{16{shifted_rdata[15]}}, shifted_rdata[15:0]}; // lh (sign-extend)
            3'b010:  formatted_load_data = shifted_rdata;                                  // lw
            3'b100:  formatted_load_data = {24'b0, shifted_rdata[7:0]};                    // lbu (zero-extend)
            3'b101:  formatted_load_data = {16'b0, shifted_rdata[15:0]};                   // lhu (zero-extend)
            default: formatted_load_data = 32'b0;
        endcase
    end

    always_comb begin
        if (is_load) begin
            rd_data_out = formatted_load_data; 
        end else begin
            // forward ALU result for arithmetic, logic, and jumps
            rd_data_out = alu_result_in;
        end
    end

endmodule
