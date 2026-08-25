module pc_reg(
    input wire clk,
    input wire rst_n,
    input wire stall,
    input wire branch,
    input wire jump,
    input wire jump_reg,

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
            if( (branch && alu_result[0]) || jump )begin
                pc <= pc + imm;
            end else if (jump_reg)begin
                pc <= {alu_result[31:1],1'b0};
            end else begin
                pc <= pc + 32'd4;
            end
        end
    end
endmodule