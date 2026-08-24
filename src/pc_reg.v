module pc_reg(
    input wire clk,
    input wire rst_n,
    input wire stall,

    output reg [31:0] pc
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            pc <= 32'b0;
        end else if (stall)begin
            pc <= pc;
        end else begin
            pc <= pc + 4;
        end
    end
endmodule