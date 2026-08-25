module ram(
    input wire clk,

    input wire [3:0] we,
    input wire [31:0] addr,
    output reg [31:0] ram_w_data,
    output reg [31:0] ram_r_data
);

    reg [31:0] ram [0:1023];//4KB
    wire [31:0] word_index = {22'b0,addr[11:2]};

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)begin
            ram[i] = 32'b0;
        end
    end

    always @(posedge clk)begin
        if(we[0]) ram[word_index][7:0] <= ram_w_data[7:0];
        if[we[1]] ram[word_index][15:8] <= ram_w_data[15:8];
        if[we[2]] ram[word_index][23:16] <= ram_w_data[23:16];
        if[we[3]] ram[word_index][31:24] <= ram_w_data[31:24];
        ram_r_data <= ram[word_index];
    end
endmodule