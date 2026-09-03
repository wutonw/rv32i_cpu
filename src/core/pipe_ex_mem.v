module pipe_ex_mem(
    input wire clk,
    input wire rst_n,

    input wire [31:0] ex_alu_result,
    output reg [31:0] ex_mem_alu_result,

    input wire id_ex_valid,
    input wire [31:0] id_ex_pc,
    input wire [31:0] id_ex_inst,
    output reg ex_mem_valid,
    output reg [31:0] ex_mem_pc,
    output reg [31:0] ex_mem_inst,

    input wire [4:0] id_ex_rd_addr,
    input wire [31:0] id_ex_rs2_data,
    output reg [4:0] ex_mem_rd_addr,
    output reg [31:0] ex_mem_rs2_data,

    input wire id_ex_wr_en,
    input wire id_ex_ext_u,
    input wire [1:0] id_ex_ram_size,
    input wire id_ex_ram_we,
    input wire [1:0] id_ex_wb_sel,
    output reg ex_mem_wr_en,
    output reg ex_mem_ext_u,
    output reg [1:0] ex_mem_ram_size,
    output reg ex_mem_ram_we,
    output reg [1:0] ex_mem_wb_sel
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ex_mem_valid <= 1'b0;
            ex_mem_wr_en <= 1'b0;
            ex_mem_ext_u <= 1'b0;
            ex_mem_ram_size <= 2'b0;
            ex_mem_ram_we <= 1'b0;
            ex_mem_wb_sel <= 2'b0;
        end else begin
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_wr_en <= id_ex_wr_en;
            ex_mem_ext_u <= id_ex_ext_u;
            ex_mem_ram_size <= id_ex_ram_size;
            ex_mem_ram_we <= id_ex_ram_we;
            ex_mem_wb_sel <= id_ex_wb_sel;
            ex_mem_valid <= id_ex_valid;
            ex_mem_pc <= id_ex_pc;
            ex_mem_inst <= id_ex_inst;
            ex_mem_rd_addr <= id_ex_rd_addr;
            ex_mem_rs2_data <= id_ex_rs2_data;
        end
    end

endmodule
