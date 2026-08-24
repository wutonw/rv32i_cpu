`include "define.vh"
module top(
    input wire clk,
    input wire raw_rst_n,

    input wire [31:0] inst,
    output wire [31:0] inst_addr
);
    wire rst_n;
    wire raw_wr_en;
    wire alu_src;
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

    wire stall = load_stall;

    wire [31:0] imm;
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
    assign wr_data = (wb_sel == 2'b00)? alu_result :
                    (wb_sel == 2'b01)? ram_r_data :
                    inst_addr;//暂时占位
    wire wr_en = raw_wr_en && (!ram_req || load_wait);
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
    ram u_ram(
        .clk(clk),
        .ram_we(ram_we),
        .addr(alu_result),
        .ram_size(ram_size),
        .ext_u(ext_u),
        .ram_w_data(),
        .ram_r_data(raw_ram_r_data)
    );
    //-----------------------
    
    //---------ALU-----------
    assign op2 = (alu_src)? imm : rs2_data;
    alu u_alu(
        .alu_op(alu_op),
        .op1(rs1_data),
        .op2(op2),
        .alu_result(alu_result)
    );
    //-----------------------

    //--------DECODER--------
    wire [1:0] wb_sel;
    decoder u_decoder(
        .inst(inst),
        .wr_en(raw_wr_en),
        .alu_src(alu_src),
        .ext_u(ext_u),
        .ram_size(ram_size),
        .ram_we(ram_we),
        .wb_sel(wb_sel),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .alu_op(alu_op)
    );
    //-----------------------

    //--------PC_REG---------
    pc_reg u_pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .pc(inst_addr)
    );
    //-----------------------

    //--------IMM_GEN--------
    imm_gen u_imm_gen(
        .inst(inst),
        .imm(imm)
    );
    //-----------------------

    //lsu选择+load_stall
    reg [31:0] ram_r_data;
    wire [31:0] shift_data = raw_ram_r_data >> {alu_result[1:0], 3'b000};
    wire ram_req = (wb_sel == 2'b01);
    always @(*)begin
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
                    if(ext_u)begin
                        ram_r_data={16'b0,shift_data[15:0]};
                    end else begin
                        ram_r_data={{16{shift_data[15]}},shift_data[15:0]};
                    end
                end
                default: ram_r_data = raw_ram_r_data;
            endcase
        end
    end
    reg load_wait;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            load_wait <= 0;
        end else begin
            if(ram_req && !load_wait)begin
                load_wait <= 1;
            end else begin
                load_wait <= 0;
            end
        end
    end
    wire load_stall = ram_req && !load_wait;
endmodule