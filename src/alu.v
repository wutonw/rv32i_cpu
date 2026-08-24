`include "define.vh"
module alu(
    input wire [3:0] alu_op,
    input wire [31:0] op1,
    input wire [31:0] op2,

    output reg [31:0] alu_result
);

    always @(*)begin
        
        case(alu_op)
            `ALU_ADD: alu_result = op1 + op2;
            `ALU_SUB: alu_result = op1 - op2;
            `ALU_SLT: alu_result = ($signed(op1)<$signed(op2));
            `ALU_SLTU: alu_result = (op1<op2);
            `ALU_XOR: alu_result = op1 ^ op2;
            `ALU_SLL: alu_result = op1 << op2[4:0];
            `ALU_SRL: alu_result = op1 >> op2[4:0];
            `ALU_SRA: alu_result = $signed(op1) >>> op2[4:0];
            `ALU_OR : alu_result = op1 | op2;
            `ALU_AND : alu_result = op1 & op2;
            `ALU_BEQ : alu_result = (op1==op2);
            `ALU_BNE: alu_result = (op1!=op2);
            `ALU_BLT: alu_result = ($signed(op1)<$signed(op2));
            `ALU_BGE: alu_result = ($signed(op1)>=$signed(op2));
            `ALU_BLTU: alu_result = (op1<op2);
            `ALU_BGEU: alu_result = (op1>=op2);
            default: alu_result = 32'b0;
        endcase
    end
endmodule