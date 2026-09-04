module pipe_mem_wb(
    input wire clk,
    input wire rst_n,

    input wire [31:0] ex_mem_pc,
    input wire [1:0] ex_mem_wb_sel,
    input wire [31:0] ex_mem_alu_result,
    input wire [31:0] mem_ram_r_data,
    input wire ex_mem_wr_en,
    input wire ex_mem_is_load,
    output reg [31:0] mem_wb_pc,
    output reg [1:0] mem_wb_wb_sel,
    output reg [31:0] mem_wb_alu_result,
    output reg [31:0] mem_wb_ram_r_data,
    output reg mem_wb_wr_en,
    output reg mem_wb_is_load,

    input wire [4:0] ex_mem_rd_addr,
    output reg [4:0] mem_wb_rd_addr,
    input wire ex_mem_valid,
    output reg mem_wb_valid
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            mem_wb_wr_en <= 1'b0;
            mem_wb_valid <= 1'b0;
            mem_wb_wb_sel <= 2'b0;
            mem_wb_is_load <= 1'b0;
        end else begin
            mem_wb_pc <= ex_mem_pc;
            mem_wb_wb_sel <= ex_mem_wb_sel;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_ram_r_data <= mem_ram_r_data;
            mem_wb_wr_en <= ex_mem_wr_en;
            mem_wb_rd_addr <= ex_mem_rd_addr;
            mem_wb_valid <= ex_mem_valid;
            mem_wb_is_load <= ex_mem_is_load;
        end
    end

endmodule
