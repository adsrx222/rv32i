`include "if_stage_b.sv"
`include "if_id_reg.sv"
`include "id_stage.sv"
`include "regfile.sv"
`include "id_ex_reg.sv"
`include "ex_stage.sv"
`include "ex_mem_reg.sv"
`include "mem_stage.sv"
`include "mem_wb_reg.sv"
`include "wb_stage.sv"

module core (
    input  logic        clk,
    input  logic        rst_n,

    // Instruction Memory Interface
    output logic        imem_req_valid,
    output logic [31:0] imem_req_addr,
    input  logic        imem_rsp_ready,
    input  logic        imem_rsp_valid,
    input  logic [31:0] imem_rsp_rdata,

    // Data Memory Interface
    output logic        dmem_req_valid,
    output logic        dmem_req_write,
    output logic [31:0] dmem_req_addr,
    output logic [31:0] dmem_req_wdata,
    output logic [3:0]  dmem_req_be,
    input  logic        dmem_req_ready,
    input  logic        dmem_rsp_valid,
    input  logic [31:0] dmem_rsp_rdata
);

    // =========================================================================
    // Inter-stage Wires & Control Signals
    // =========================================================================

    logic global_stall;
    logic branch_taken;
    logic [31:0] branch_target_pc;
    
    // FIX: Only redirect and flush when EX is not globally stalled
    logic redirect;
    assign redirect = branch_taken && !global_stall;
    
    // PC
    logic [31:0] pc_reg;

    // IF -> IF/ID
    logic        if_inst_valid;
    logic [31:0] if_inst;
    logic [31:0] if_pc; // Synchronized PC from fetch stage

    // IF/ID -> ID
    logic [31:0] id_pc_in;
    logic [31:0] id_inst;
    logic        id_inst_valid;

    // ID / Regfile
    logic [4:0]  rf_rs1_addr, rf_rs2_addr;
    logic [31:0] rf_rs1_data, rf_rs2_data;

    // ID -> ID/EX
    logic [31:0] id_pc_out;
    logic [31:0] id_rs1_val, id_rs2_val, id_imm;
    logic [4:0]  id_rd_addr;
    logic [2:0]  id_funct3;
    logic [6:0]  id_funct7;
    logic [6:0]  id_opcode;
    logic        id_inst_valid_out;

    // ID/EX -> EX
    logic [31:0] ex_pc_in;
    logic [31:0] ex_rs1_val, ex_rs2_val_in, ex_imm;
    logic [4:0]  ex_rd_addr_in;
    logic [2:0]  ex_funct3_in;
    logic [6:0]  ex_funct7, ex_opcode_in;

    // EX -> EX/MEM
    logic [31:0] ex_pc_out, ex_alu_result, ex_rs2_val_out;
    logic [4:0]  ex_rd_addr_out;
    logic [2:0]  ex_funct3_out;
    logic [6:0]  ex_opcode_out;

    // EX/MEM -> MEM
    logic [31:0] mem_pc_in; // Unused but kept for interface consistency
    logic [31:0] mem_alu_result_in, mem_rs2_val;
    logic [4:0]  mem_rd_addr_in;
    logic [2:0]  mem_funct3_in;
    logic [6:0]  mem_opcode_in;

    // MEM -> MEM/WB
    logic [31:0] mem_alu_result_out;
    logic [4:0]  mem_rd_addr_out;
    logic [2:0]  mem_funct3_out;
    logic [6:0]  mem_opcode_out;
    logic [1:0]  mem_byte_offset_out;

    // MEM/WB -> WB
    logic [31:0] wb_alu_result;
    logic [4:0]  wb_rd_addr_in;
    logic [2:0]  wb_funct3;
    logic [6:0]  wb_opcode;
    logic [1:0]  wb_byte_offset;

    // WB -> Regfile
    logic        wb_reg_write_en;
    logic [4:0]  wb_rd_addr;
    logic [31:0] wb_rd_data;

    // =========================================================================
    // Hazard Detection Logic (FIX: Minimum viable interlock)
    // =========================================================================
    
    function automatic logic writes_rd(input logic [6:0] op);
        return op inside {7'b0110011,7'b0010011,7'b0000011,7'b0110111,7'b0010111,7'b1101111,7'b1100111};
    endfunction
    
    function automatic logic hit(input logic [6:0] op, input logic [4:0] rd, input logic [4:0] rs);
        return writes_rd(op) && rd != 5'd0 && rd == rs;
    endfunction
    
    logic raw_hazard;
    assign raw_hazard =
       hit(id_opcode,     id_rd_addr,      rf_rs1_addr) || hit(id_opcode,     id_rd_addr,      rf_rs2_addr) ||
       hit(ex_opcode_in,  ex_rd_addr_in,   rf_rs1_addr) || hit(ex_opcode_in,  ex_rd_addr_in,   rf_rs2_addr) ||
       hit(ex_opcode_out, ex_rd_addr_out,  rf_rs1_addr) || hit(ex_opcode_out, ex_rd_addr_out,  rf_rs2_addr) ||
       hit(mem_opcode_in, mem_rd_addr_in,  rf_rs1_addr) || hit(mem_opcode_in, mem_rd_addr_in,  rf_rs2_addr);

    // =========================================================================
    // Program Counter Logic
    // =========================================================================
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'h0000_0000;
        end else if (redirect) begin
            // FIX: Use `redirect` instead of `branch_taken` to respect global_stall
            pc_reg <= branch_target_pc;
        end else if (!global_stall && !raw_hazard) begin
            // FIX: Stall the PC from advancing while a RAW hazard exists
            pc_reg <= pc_reg + 4;
        end
    end

    // =========================================================================
    // Stage Instantiations
    // =========================================================================

    if_stage_b if_stage_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(redirect), // FIX: Use redirect for flush
        .stall(global_stall || raw_hazard), // FIX: Stall frontend on raw hazard
        .pc(pc_reg),
        .inst_valid(if_inst_valid),
        .inst(if_inst),
        .inst_pc(if_pc),
        .req_valid(imem_req_valid),
        .req_addr(imem_req_addr),
        .rsp_ready(imem_rsp_ready),
        .rsp_valid(imem_rsp_valid),
        .rsp_rdata(imem_rsp_rdata)
    );

    if_id_reg if_id_reg_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(redirect), // FIX: Use redirect for flush
        .stall(global_stall || raw_hazard), // FIX: Stall frontend on raw hazard
        .pc_in(if_pc),
        .instr_in(if_inst),
        .inst_valid_in(if_inst_valid),
        .pc_out(id_pc_in),
        .instr_out(id_inst),
        .inst_valid_out(id_inst_valid)
    );

    id_stage id_stage_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(redirect || raw_hazard), // FIX: Feed ID stage a bubble on raw hazard or branch
        .stall(global_stall), // Do not use global stall here to let producers drain
        .pc_in(id_pc_in),
        .instr_in(id_inst),
        .inst_valid_in(id_inst_valid),
        .rs1_addr(rf_rs1_addr),
        .rs2_addr(rf_rs2_addr),
        .rs1_rsp(rf_rs1_data),
        .rs2_rsp(rf_rs2_data),
        .pc_out(id_pc_out),
        .rs1_val_out(id_rs1_val),
        .rs2_val_out(id_rs2_val),
        .imm_out(id_imm),
        .rd_addr_out(id_rd_addr),
        .funct3_out(id_funct3),
        .funct7_out(id_funct7),
        .opcode_out(id_opcode),
        .inst_valid_out(id_inst_valid_out)
    );

    regfile regfile_inst (
        .clk(clk), .rst_n(rst_n),
        .rs1_addr(rf_rs1_addr),
        .rs1_data(rf_rs1_data),
        .rs2_addr(rf_rs2_addr),
        .rs2_data(rf_rs2_data),
        .reg_write_en(wb_reg_write_en),
        .rd_addr(wb_rd_addr),
        .rd_data(wb_rd_data)
    );

    id_ex_reg id_ex_reg_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(redirect), // FIX: Use redirect for flush
        .stall(global_stall),
        .pc_in(id_pc_out),
        .rs1_val_in(id_rs1_val),
        .rs2_val_in(id_rs2_val),
        .imm_in(id_imm),
        .rd_addr_in(id_rd_addr),
        .funct3_in(id_funct3),
        .funct7_in(id_funct7),
        .opcode_in(id_opcode),
        .pc_out(ex_pc_in),
        .rs1_val_out(ex_rs1_val),
        .rs2_val_out(ex_rs2_val_in),
        .imm_out(ex_imm),
        .rd_addr_out(ex_rd_addr_in),
        .funct3_out(ex_funct3_in),
        .funct7_out(ex_funct7),
        .opcode_out(ex_opcode_in)
    );

    ex_stage ex_stage_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(1'b0),
        .stall(global_stall),
        .pc_in(ex_pc_in),
        .rs1_val_in(ex_rs1_val),
        .rs2_val_in(ex_rs2_val_in),
        .imm_in(ex_imm),
        .rd_addr_in(ex_rd_addr_in),
        .funct3_in(ex_funct3_in),
        .funct7_in(ex_funct7),
        .opcode_in(ex_opcode_in),
        .pc_out(ex_pc_out),
        .alu_result_out(ex_alu_result),
        .rs2_val_out(ex_rs2_val_out),
        .rd_addr_out(ex_rd_addr_out),
        .funct3_out(ex_funct3_out),
        .opcode_out(ex_opcode_out),
        .branch_taken(branch_taken),
        .branch_target_pc(branch_target_pc)
    );

    ex_mem_reg ex_mem_reg_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(1'b0),
        .stall(global_stall),
        .pc_in(ex_pc_out),
        .alu_result_in(ex_alu_result),
        .rs2_val_in(ex_rs2_val_out),
        .rd_addr_in(ex_rd_addr_out),
        .funct3_in(ex_funct3_out),
        .opcode_in(ex_opcode_out),
        .pc_out(mem_pc_in),
        .alu_result_out(mem_alu_result_in),
        .rs2_val_out(mem_rs2_val),
        .rd_addr_out(mem_rd_addr_in),
        .funct3_out(mem_funct3_in),
        .opcode_out(mem_opcode_in)
    );

    mem_stage mem_stage_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(1'b0),
        .stall(global_stall),
        .alu_result_in(mem_alu_result_in),
        .rs2_val_in(mem_rs2_val),
        .rd_addr_in(mem_rd_addr_in),
        .funct3_in(mem_funct3_in),
        .opcode_in(mem_opcode_in),
        .req_valid(dmem_req_valid),
        .req_write(dmem_req_write),
        .req_addr(dmem_req_addr),
        .req_wdata(dmem_req_wdata),
        .req_be(dmem_req_be),
        .req_ready(dmem_req_ready),
        .alu_result_out(mem_alu_result_out),
        .rd_addr_out(mem_rd_addr_out),
        .funct3_out(mem_funct3_out),
        .opcode_out(mem_opcode_out),
        .byte_offset_out(mem_byte_offset_out)
    );

    mem_wb_reg mem_wb_reg_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(1'b0),
        .stall(global_stall),
        .alu_result_in(mem_alu_result_out),
        .rd_addr_in(mem_rd_addr_out),
        .funct3_in(mem_funct3_out),
        .opcode_in(mem_opcode_out),
        .byte_offset_in(mem_byte_offset_out),
        .alu_result_out(wb_alu_result),
        .rd_addr_out(wb_rd_addr_in),
        .funct3_out(wb_funct3),
        .opcode_out(wb_opcode),
        .byte_offset_out(wb_byte_offset)
    );

    wb_stage wb_stage_inst (
        .clk(clk), .rst_n(rst_n),
        .flush(1'b0),
        .stall(1'b0),
        .alu_result_in(wb_alu_result),
        .rd_addr_in(wb_rd_addr_in),
        .funct3_in(wb_funct3),
        .opcode_in(wb_opcode),
        .byte_offset_in(wb_byte_offset),
        .rsp_valid(dmem_rsp_valid),
        .rsp_rdata(dmem_rsp_rdata),
        .reg_write_en(wb_reg_write_en),
        .rd_addr_out(wb_rd_addr),
        .rd_data_out(wb_rd_data),
        .wb_stall_req(global_stall)
    );

endmodule
