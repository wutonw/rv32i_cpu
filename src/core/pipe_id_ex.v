module pipe_id_ex(
    input wire clk,
    input wire rst_n,
    input wire id_ex_flush,

    input wire if_id_valid,
    input wire [31:0] if_id_pc,
    input wire [31:0] if_id_inst,
    output reg id_ex_valid,
    output reg [31:0] id_ex_pc,
    output reg [31:0] id_ex_inst,

    input wire [4:0] id_rs1_addr,
    input wire [4:0] id_rs2_addr,
    input wire [4:0] id_rd_addr,
    input wire [31:0] id_rs1_data,
    input wire [31:0] id_rs2_data,
    input wire [31:0] id_imm,
    output reg [4:0] id_ex_rs1_addr,
    output reg [4:0] id_ex_rs2_addr,
    output reg [4:0] id_ex_rd_addr,
    output reg [31:0] id_ex_rs1_data,
    output reg [31:0] id_ex_rs2_data,
    output reg [31:0] id_ex_imm,

    input wire id_wr_en,
    input wire id_illegal_inst,
    input wire [1:0] id_alu_src_op1,
    input wire id_alu_src_op2,
    input wire id_ext_u,
    input wire [1:0] id_ram_size,
    input wire id_ram_we,
    input wire [1:0] id_wb_sel,
    input wire id_branch,
    input wire id_jump,
    input wire id_jump_reg,
    input wire id_decode_trap_enter,
    input wire id_trap_exit,
    input wire id_csr_we,
    output reg id_ex_wr_en,
    output reg id_ex_illegal_inst,
    output reg [1:0] id_ex_alu_src_op1,
    output reg id_ex_alu_src_op2,
    output reg id_ex_ext_u,
    output reg [1:0] id_ex_ram_size,
    output reg id_ex_ram_we,
    output reg [1:0] id_ex_wb_sel,
    output reg id_ex_branch,
    output reg id_ex_jump,
    output reg id_ex_jump_reg,
    output reg id_ex_decode_trap_enter,
    output reg id_ex_trap_exit,
    output reg id_ex_csr_we,

    input wire [3:0] id_alu_op,
    output reg [3:0] id_ex_alu_op
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            id_ex_valid <= 1'b0;
            id_ex_wr_en <= 1'b0;
            id_ex_illegal_inst <= 1'b0;
            id_ex_alu_src_op1 <= 2'b0;
            id_ex_alu_src_op2 <= 1'b0;
            id_ex_ext_u <= 1'b0;
            id_ex_ram_size <= 2'b0;
            id_ex_ram_we <= 1'b0;
            id_ex_wb_sel <= 2'b0;
            id_ex_branch <= 1'b0;
            id_ex_jump <= 1'b0;
            id_ex_jump_reg <= 1'b0;
            id_ex_csr_we <= 1'b0;
            id_ex_decode_trap_enter <= 1'b0;
            id_ex_trap_exit <= 1'b0;
            id_ex_alu_op <= 4'b0;
        end else if (id_ex_flush)begin
            id_ex_valid <= 1'b0;
            id_ex_wr_en <= 1'b0;
            id_ex_illegal_inst <= 1'b0;
            id_ex_alu_src_op1 <= 2'b0;
            id_ex_alu_src_op2 <= 1'b0;
            id_ex_ext_u <= 1'b0;
            id_ex_ram_size <= 2'b0;
            id_ex_ram_we <= 1'b0;
            id_ex_wb_sel <= 2'b0;
            id_ex_branch <= 1'b0;
            id_ex_jump <= 1'b0;
            id_ex_jump_reg <= 1'b0;
            id_ex_csr_we <= 1'b0;
            id_ex_decode_trap_enter <= 1'b0;
            id_ex_trap_exit <= 1'b0;
            id_ex_alu_op <= 4'b0;
        end else begin
            id_ex_valid <= if_id_valid;
            id_ex_pc <= if_id_pc;
            id_ex_inst <= if_id_inst;
            id_ex_rs1_addr <= id_rs1_addr;
            id_ex_rs2_addr <= id_rs2_addr;
            id_ex_rd_addr <= id_rd_addr;
            id_ex_rs1_data <= id_rs1_data;
            id_ex_rs2_data <= id_rs2_data;
            id_ex_imm <= id_imm;
            id_ex_wr_en <= id_wr_en;
            id_ex_illegal_inst <= id_illegal_inst;
            id_ex_alu_src_op1 <= id_alu_src_op1;
            id_ex_alu_src_op2 <= id_alu_src_op2;
            id_ex_ext_u <= id_ext_u;
            id_ex_ram_size <= id_ram_size;
            id_ex_ram_we <= id_ram_we;
            id_ex_wb_sel <= id_wb_sel;
            id_ex_branch <= id_branch;
            id_ex_jump <= id_jump;
            id_ex_jump_reg <= id_jump_reg;
            id_ex_decode_trap_enter <= id_decode_trap_enter;
            id_ex_trap_exit <= id_trap_exit;
            id_ex_csr_we <= id_csr_we;
            id_ex_alu_op <= id_alu_op;
        end
    end
endmodule
