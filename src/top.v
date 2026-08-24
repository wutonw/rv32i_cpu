module top(
    input wire clk,
    input wire raw_rst_n,

    input wire [31:0] inst,
    output wire [31:0] inst_addr
);
    wire rst_n;
    wire wr_en;
    wire [31:0] wr_data;
    wire [3:0] alu_op;
    wire [31:0] rs1_addr;
    wire [31:0] rs2_addr;
    wire [31:0] rd_addr;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    //-------DEBOUNCE--------
    debounce u_debounce(
        .clk(clk),
        .key_in(raw_rst_n),
        .key_out(rst_n)
    );
    //-----------------------
    
    //--------REGFILE--------
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
    
    //---------ALU------------
    alu u_alu(
        .alu_op(alu_op),
        .op1(rs1_data),
        .op2(rs2_data),
        .result(wr_data),
    );
    //-----------------------

    //--------DECODER--------
    decoder u_decoder(
        .inst(inst),
        .wr_en(wr_en),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .alu_op(alu_op)
    );
    //-----------------------

endmodule