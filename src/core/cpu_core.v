`include "define.vh"
module cpu_core(
    input wire clk,
    input wire raw_rst_n,

    input wire [31:0] inst,
    output wire [31:0] inst_addr
);
    wire [31:0] pc;
    wire trap_enter;
    assign inst_addr = pc;
    wire rst_n;
    wire raw_wr_en;
    wire [1:0] alu_src_op1;
    wire alu_src_op2;
    wire ram_we;
    wire ext_u;
    wire [1:0] ram_size;
    wire [31:0] wr_data;
    wire [3:0] alu_op;
    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [4:0] rd_addr;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] raw_ram_r_data;

    wire [11:0] csr_addr;
    reg [31:0] csr_w_data;
    wire [31:0] csr_r_data;
    wire csr_we;
    wire trap_exit;
    wire [31:0] trap_pc;
    wire [31:0] trap_vector;
    wire [31:0] mepc_out;
    wire global_intr_en;


    wire stall = load_stall;

    wire [31:0] imm;
    wire [31:0] op1;
    wire [31:0] op2;
    //-------DEBOUNCE--------
    debounce u_debounce(
        .clk(clk),
        .key_in(raw_rst_n),
        .key_out(rst_n)
    );
    //-----------------------
    
    //--------REGFILE--------
    wire [31:0] alu_result;
    wire [31:0] pc_plus_4 = pc + 32'd4;
    assign wr_data = (wb_sel == 2'b00)? alu_result :
                    (wb_sel == 2'b01)? ram_r_data :
                    (wb_sel == 2'b10)? pc_plus_4 :
                    csr_r_data;
    wire wr_en = raw_wr_en && (!ram_req || load_wait) && ~trap_enter;
    regfile u_regfile(
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_addr(rd_addr),
        .wr_data(wr_data),
        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data),
        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data)
    );
    //-----------------------

    //---------RAM-----------
    reg [3:0] tmp_ram_s_we;
    wire [3:0] ram_s_we = tmp_ram_s_we & ~{4{trap_enter}};
    reg [31:0] ram_w_data;
    ram u_ram(
        .clk(clk),
        .we(ram_s_we),
        .addr(alu_result),
        .ram_w_data(ram_w_data),
        .ram_r_data(raw_ram_r_data)
    );
    //-----------------------
    
    //---------ALU-----------
    assign op1= (alu_src_op1 == 2'b00) ? rs1_data :
                (alu_src_op1== 2'b01) ? 32'b0 :
                pc;
    assign op2 = (alu_src_op2)? imm : rs2_data;
    alu u_alu(
        .alu_op(alu_op),
        .op1(op1),
        .op2(op2),
        .alu_result(alu_result)
    );
    //-----------------------

    //--------DECODER--------
    wire decode_trap_enter;
    wire illegal_inst;
    wire [1:0] wb_sel;
    wire branch;
    wire jump;
    wire jump_reg;
    decoder u_decoder(
        .inst(inst),
        .wr_en(raw_wr_en),
        .illegal_inst(illegal_inst),
        .alu_src_op1(alu_src_op1),
        .alu_src_op2(alu_src_op2),
        .ext_u(ext_u),
        .ram_size(ram_size),
        .ram_we(ram_we),
        .wb_sel(wb_sel),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .decode_trap_enter(decode_trap_enter),
        .trap_exit(trap_exit),
        .csr_we(csr_we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .csr_addr(csr_addr),
        .alu_op(alu_op)
    );
    //-----------------------

    //--------PC_REG---------
    wire [31:0] target_addr = jump_reg ? {alu_result[31:1], 1'b0} :
                            (jump || (branch && alu_result[0])) ? pc + imm :
                            32'b0;
    wire inst_address_misaligned = (jump_reg || jump || (branch && alu_result[0])) &&
                                        (target_addr[1:0] !=2'b0);
    pc_reg u_pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .imm(imm),
        .alu_result(alu_result),
        .trap_enter(trap_enter),
        .trap_exit(trap_exit),
        .trap_vector(trap_vector),
        .mepc_out(mepc_out),
        .pc(pc)
    );
    //-----------------------

    //------CSR_FILE---------
    assign trap_enter = decode_trap_enter || illegal_inst
                    ||load_misaligned || store_misaligned || inst_address_misaligned;
    reg [31:0] trap_cause;
    assign trap_pc = pc;
    csr_file u_csr_file(
        .clk(clk),
        .rst_n(rst_n),
        .csr_addr(csr_addr),
        .csr_w_data(csr_w_data),
        .csr_we(csr_we),
        .csr_r_data(csr_r_data),
        .trap_enter(trap_enter),
        .trap_pc(trap_pc),
        .trap_cause(trap_cause),
        .trap_vector(trap_vector),
        .trap_exit(trap_exit),
        .mepc_out(mepc_out),
        .global_intr_en(global_intr_en)
    );
    //-----------------------

    //--------IMM_GEN--------
    imm_gen u_imm_gen(
        .inst(inst),
        .imm(imm)
    );
    //-----------------------

    //lsu选择+load_stall
    reg load_misaligned;
    reg load_wait;
    reg [31:0] ram_r_data;
    wire [31:0] shift_data = raw_ram_r_data >> {alu_result[1:0], 3'b000};
    wire ram_req = (wb_sel == 2'b01);
    always @(*)begin
        load_misaligned = 0;
        ram_r_data = raw_ram_r_data;
        if(inst[6:0] == `OP_LOAD)begin
            case(ram_size)
                2'b00:begin
                    if(ext_u)begin
                        ram_r_data={24'b0,shift_data[7:0]};
                    end else begin
                        ram_r_data={{24{shift_data[7]}},shift_data[7:0]};
                    end
                end
                2'b01:begin
                    if (alu_result[0] == 0)begin
                        if(ext_u)begin
                            ram_r_data={16'b0,shift_data[15:0]};
                        end else begin
                            ram_r_data={{16{shift_data[15]}},shift_data[15:0]};
                        end
                    end else begin
                        load_misaligned = 1;
                    end
                end
                2'b10:begin
                    if (alu_result[1:0] == 2'b0)begin
                        ram_r_data = raw_ram_r_data;
                    end else begin
                        load_misaligned = 1;
                    end
                end
                default: ;
            endcase
        end
    end
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n || trap_enter)begin
            load_wait <= 0;
        end else begin
            if(ram_req && !load_wait)begin
                load_wait <= 1;
            end else begin
                load_wait <= 0;
            end
        end
    end
    wire load_stall = ram_req && !load_wait && !trap_enter;

    //store
    reg store_misaligned;
    wire [2:0] tmp = {ext_u,ram_size};
    always @(*)begin
        tmp_ram_s_we = 4'b0;
        ram_w_data = rs2_data;
        store_misaligned = 0;
        if(ram_we)begin
            case(tmp)
                3'b000:begin
                    ram_w_data = {4{rs2_data[7:0]}};
                    tmp_ram_s_we = 4'b0001 << alu_result[1:0];
                end
                3'b001:begin
                    if(alu_result[0] == 0)begin
                        ram_w_data = {2{rs2_data[15:0]}};
                        tmp_ram_s_we = (alu_result[1]) ? 4'b1100 : 4'b0011;
                    end else begin
                        store_misaligned = 1;
                    end
                end
                3'b010:begin
                    if(alu_result[1:0] == 2'b0)begin
                        tmp_ram_s_we = 4'b1111;
                    end else begin
                        store_misaligned = 1;
                    end
                end
                default: ;
            endcase
        end
    end
    
    //csr
    wire [31:0] zimm_32 = {27'b0 , rs1_addr};
    always @(*)begin
        case(inst[14:12])
            3'b001: csr_w_data = rs1_data;
            3'b010: csr_w_data = csr_r_data | rs1_data;
            3'b011: csr_w_data = csr_r_data & ~rs1_data;
            3'b101: csr_w_data = zimm_32;
            3'b110: csr_w_data = csr_r_data | zimm_32;
            3'b111: csr_w_data = csr_r_data & ~zimm_32;
            default : csr_w_data = csr_r_data;
        endcase
    end

    //trap_cause
    always @(*)begin
        trap_cause = 0;
        if(illegal_inst)begin
            trap_cause = 2;
        end else if (load_misaligned)begin
            trap_cause = 4;
        end else if (store_misaligned)begin
            trap_cause = 6;
        end else if (decode_trap_enter)begin
            if(inst[31:20] == 12'h000)begin
                //ecall
                trap_cause = 11;
            end else if(inst[31:20] == 12'h001)begin
                //ebreak
                trap_cause = 3;
            end
        end else if (inst_address_misaligned)begin
            trap_cause = 0;
        end
    end
endmodule