module ex_stage (
    // control signals
    input  logic        clk,     // Unused after fix
    input  logic        rst_n,   // Unused after fix
    input  logic        flush,   // Unused after fix
    input  logic        stall,   // Unused after fix

    // inputs from id/ex pipeline register
    input  logic [31:0] pc_in,
    input  logic [31:0] rs1_val_in,
    input  logic [31:0] rs2_val_in,
    input  logic [31:0] imm_in,
    input  logic [4:0]  rd_addr_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  funct7_in,
    input  logic [6:0]  opcode_in,

    // outputs to ex/mem pipeline register
    output logic [31:0] pc_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] rs2_val_out,
    output logic [4:0]  rd_addr_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  opcode_out,

    // branch / jump resolution outputs
    output logic        branch_taken,
    output logic [31:0] branch_target_pc
);

    // branching
    
    logic branch_cond;
    always_comb begin
        case (funct3_in)
            3'b000:  branch_cond = (rs1_val_in == rs2_val_in);                  // beq
            3'b001:  branch_cond = (rs1_val_in != rs2_val_in);                  // bne
            3'b100:  branch_cond = ($signed(rs1_val_in) < $signed(rs2_val_in)); // blt
            3'b101:  branch_cond = ($signed(rs1_val_in) >= $signed(rs2_val_in));// bge
            3'b110:  branch_cond = (rs1_val_in < rs2_val_in);                   // bltu
            3'b111:  branch_cond = (rs1_val_in >= rs2_val_in);                  // bgeu
            default: branch_cond = 1'b0;
        endcase
    end

    logic is_branch, is_jal, is_jalr;
    assign is_branch = (opcode_in == 7'b1100011);
    assign is_jal    = (opcode_in == 7'b1101111);
    assign is_jalr   = (opcode_in == 7'b1100111);

    assign branch_taken = (is_branch && branch_cond) || is_jal || is_jalr;

    always_comb begin
        if (is_jalr) begin
            branch_target_pc = (rs1_val_in + imm_in) & ~32'h1; // jalr aligns target to even address
        end else begin
            branch_target_pc = pc_in + imm_in;                 // branch and jal relative target
        end
    end

    // alu
    
    logic [31:0] alu_op_a;
    logic [31:0] alu_op_b;

    always_comb begin
        case (opcode_in)
            7'b0010111, // auipc
            7'b1101111, // jal
            7'b1100111: // jalr
                alu_op_a = pc_in;
            default:
                alu_op_a = rs1_val_in;
        endcase
    end

    always_comb begin
        case (opcode_in)
            7'b0110011, // r-type arithmetic
            7'b1100011: // b-type branch
                alu_op_b = rs2_val_in;
            7'b1101111, // jal return link (pc + 4)
            7'b1100111: // jalr return link (pc + 4)
                alu_op_b = 32'd4;
            default:    // i-type, s-type, u-type
                alu_op_b = imm_in;
        endcase
    end

    // alu result

    logic [31:0] alu_result_comb;

    always_comb begin
        case (opcode_in)
            7'b0110111: begin // lui
                alu_result_comb = imm_in;
            end

            7'b0010111, // auipc
            7'b1101111, // jal
            7'b1100111, // jalr
            7'b0000011, // load address
            7'b0100011: begin // store address
                alu_result_comb = alu_op_a + alu_op_b;
            end

            7'b0010011: begin // i-type arithmetic
                case (funct3_in)
                    3'b000:  alu_result_comb = alu_op_a + alu_op_b;                         // addi
                    3'b010:  alu_result_comb = ($signed(alu_op_a) < $signed(alu_op_b)) ? 32'd1 : 32'd0; // slti
                    3'b011:  alu_result_comb = (alu_op_a < alu_op_b) ? 32'd1 : 32'd0;      // sltiu
                    3'b100:  alu_result_comb = alu_op_a ^ alu_op_b;                         // xori
                    3'b110:  alu_result_comb = alu_op_a | alu_op_b;                         // ori
                    3'b111:  alu_result_comb = alu_op_a & alu_op_b;                         // andi
                    3'b001:  alu_result_comb = alu_op_a << alu_op_b[4:0];                   // slli
                    3'b101: begin
                        if (funct7_in[5])
                            alu_result_comb = $signed(alu_op_a) >>> alu_op_b[4:0];       // srai
                        else
                            alu_result_comb = alu_op_a >> alu_op_b[4:0];                  // srli
                    end
                    default: alu_result_comb = 32'b0;
                endcase
            end

            7'b0110011: begin // r-type arithmetic
                case (funct3_in)
                    3'b000: begin
                        if (funct7_in[5])
                            alu_result_comb = alu_op_a - alu_op_b;                         // sub
                        else
                            alu_result_comb = alu_op_a + alu_op_b;                         // add
                    end
                    3'b001:  alu_result_comb = alu_op_a << alu_op_b[4:0];                   // sll
                    3'b010:  alu_result_comb = ($signed(alu_op_a) < $signed(alu_op_b)) ? 32'd1 : 32'd0; // slt
                    3'b011:  alu_result_comb = (alu_op_a < alu_op_b) ? 32'd1 : 32'd0;      // sltu
                    3'b100:  alu_result_comb = alu_op_a ^ alu_op_b;                         // xor
                    3'b101: begin
                        if (funct7_in[5])
                            alu_result_comb = $signed(alu_op_a) >>> alu_op_b[4:0];       // sra
                        else
                            alu_result_comb = alu_op_a >> alu_op_b[4:0];                  // srl
                    end
                    3'b110:  alu_result_comb = alu_op_a | alu_op_b;                         // or
                    3'b111:  alu_result_comb = alu_op_a & alu_op_b;                         // and
                    default: alu_result_comb = 32'b0;
                endcase
            end

            default: alu_result_comb = 32'b0;
        endcase
    end

    // FIX: Removed duplicated ex/mem pipeline register logic (always_ff). Stage is now purely combinational.
    assign pc_out         = pc_in;
    assign alu_result_out = alu_result_comb;
    assign rs2_val_out    = rs2_val_in;
    assign rd_addr_out    = rd_addr_in;
    assign funct3_out     = funct3_in;
    assign opcode_out     = opcode_in;

endmodule
