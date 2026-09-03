module ram(
    input wire clk,

    input wire [3:0] we,
    input wire [31:0] rd_addr,
    input wire [31:0] wr_addr,
    input wire [31:0] ram_w_data,
    output reg [31:0] ram_r_data
);

    reg [31:0] ram [0:8191];//32KB
    wire [12:0] wr_index = wr_addr[14:2];
    wire [12:0] rd_index = rd_addr[14:2];

    always @(posedge clk)begin
        if(we[0]) ram[wr_index][7:0] <= ram_w_data[7:0];
        if(we[1]) ram[wr_index][15:8] <= ram_w_data[15:8];
        if(we[2]) ram[wr_index][23:16] <= ram_w_data[23:16];
        if(we[3]) ram[wr_index][31:24] <= ram_w_data[31:24];
        ram_r_data <= ram[rd_index];
    end
endmodule