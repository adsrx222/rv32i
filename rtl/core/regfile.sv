module regfile (
    input  logic        clk,
    input  logic        rst_n,

    // read port 1
    input  logic [4:0]  rs1_addr,
    output logic [31:0] rs1_data,

    // read port 2
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs2_data,

    // write port 1
    input  logic        reg_write_en,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data
);

    // 32 integer registers of 32 bit width
    logic [31:0] registers [31:0];

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 : 
                      (reg_write_en && (rs1_addr == rd_addr)) ? rd_data : 
                      registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 : 
                      (reg_write_en && (rs2_addr == rd_addr)) ? rd_data : 
                      registers[rs2_addr];

    // Writes ignored if destination is x0
    // FIX: Added negedge rst_n to sensitivity list
    always_ff @(posedge clk or negedge rst_n) begin
        // FIX: Added reset logic to initialize all registers to 0
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= '0;
            end
        end else if (reg_write_en && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule
