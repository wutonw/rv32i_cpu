module cpu_core(
    input wire clk,
    input wire rst_n,

    input wire [31:0] inst,
    output wire [31:0] inst_addr
);
    assign inst_addr = pc;
    wire stall;
    // ==================================================
    // IF Stage
    wire [31:0] next_pc;
    wire [31:0] pc;
    pc_reg u_pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .next_pc(next_pc),
        .pc(pc)
    );
    // ==================================================

    // ==================================================
    // IF/ID Pipeline Register
    wire [31:0] if_id_inst;
    wire [31:0] if_id_pc;
    wire if_id_valid;
    pipe_if_id u_pipe_if_id(
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .pc(pc),
        .inst(inst),
        .if_id_inst(if_id_inst),
        .if_id_pc(if_id_pc),
        .if_id_valid(if_id_valid)
    );
    // ==================================================

    // ==================================================
    // ID Stage
    wire id_wr_en;
    wire id_illegal_inst;
    wire [1:0] id_alu_src_op1;
    wire id_alu_src_op2;
    wire id_ext_u;
    wire [1:0] id_ram_size;
    wire id_ram_we;
    wire [1:0] id_wb_sel;
    wire id_branch;
    wire id_jump;
    wire id_jump_reg;
    wire id_decode_trap_enter;
    wire id_trap_exit;
    wire id_csr_we;
    wire [4:0] id_rs1_addr;
    wire [4:0] id_rs2_addr;
    wire [4:0] id_rd_addr;
    wire [11:0] id_csr_addr;
    wire [3:0] id_alu_op;
    decoder u_decoder(
        .inst(if_id_inst),
        .wr_en(id_wr_en),
        .illegal_inst(id_illegal_inst),
        .alu_src_op1(id_alu_src_op1),
        .alu_src_op2(id_alu_src_op2),
        .ext_u(id_ext_u),
        .ram_size(id_ram_size),
        .ram_we(id_ram_we),
        .wb_sel(id_wb_sel),
        .branch(id_branch),
        .jump(id_jump),
        .jump_reg(id_jump_reg),
        .decode_trap_enter(id_decode_trap_enter),
        .trap_exit(id_trap_exit),
        .csr_we(id_csr_we),
        .rs1_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .rd_addr(id_rd_addr),
        .csr_addr(id_csr_addr),
        .alu_op(id_alu_op)
    );
    imm_gen u_imm_gen(
        .inst(if_id_inst),

    );
    // ==================================================

    // ==================================================
    // ID/EX Pipeline Register
    // ==================================================

    // ==================================================
    // EX Stage
    // ==================================================

    // ==================================================
    // EX/MEM Pipeline Register
    // ==================================================

    // ==================================================
    // MEM Stage
    // ==================================================

    // ==================================================
    // MEM/WB Pipeline Register
    // ==================================================

    // ==================================================
    // WB Stage
    // ==================================================

endmodule