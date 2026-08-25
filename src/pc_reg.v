module pc_reg(
    input wire clk,
    input wire rst_n,
    input wire stall,
    input wire branch,

    input wire [31:0] imm,
    input wire [31:0] alu_result,

    output reg [31:0] pc
);
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            pc <= 32'b0;
        end else if (stall)begin
            pc <= pc;
        end else begin
            if(branch && alu_result[0])begin
                pc <= pc + imm;
            end else begin
                pc <= pc + 32'd4;
            end
        end
    end
endmodule