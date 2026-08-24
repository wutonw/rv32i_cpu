module ram(
    input wire clk,

    input wire ram_we,
    input wire [31:0] addr,
    input wire [1:0] ram_size,
    input wire ext_u,
    output reg [31:0] ram_w_data,
    output reg [31:0] ram_r_data
);

    reg [31:0] ram [0:1023];//4KB

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)begin
            ram[i] = 32'b0;
        end
    end

    always @(posedge clk)begin

        ram_r_data <= ram[addr[11:2]];

    end
endmodule