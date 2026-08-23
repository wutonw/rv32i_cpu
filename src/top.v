module top(
    input wire clk,
    input wire raw_rst_n,

    input wire [31:0] inst,
    output wire [31:0] inst_addr
);
    //-------DEBOUNCE--------
    wire rst_n;
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
        .wr_en(),
        .wr_addr(),
        .wr_data(),
        .rs1_addr(),
        .rs1_data(),
        .rs2_addr(),
        .rs2_data()
    );
    //-----------------------
endmodule