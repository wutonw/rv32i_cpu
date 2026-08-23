module alu(
    input wire [3:0] alu_op,
    input wire [31:0] op1,
    input wire [31:0] op2,

    output wire [31:0] alu_result
);

    always @(*)begin
        case(alu_op)
            `ALU_ADD: result = op1 + op2;
            `ALU_SUB: result = op1 - op2;
            `ALU_SLT: result = ($signed(op1)<$signed(op2));
            `ALU_SLTU: result = (op1<op2)? 32'b1 : 32'b0;
            `ALU_XOR: result = op1 ^ op2;
            `ALU_SLL: result = op1 << op2[4:0];
            `ALU_SRL: result = op1 >> op2[4:0];
            `ALU_SRA: result = $signed(op1) >>> op2[4:0];
            `ALU_OR : result = op1 | op2;
            `ALU_AND : result = op1 & op2;
            `ALU_BEQ : result = (op1==op2);
            `ALU_BNE: result = (op1!=op2);
            `ALU_BLT: result = ($signed(op1)<$signed(op2));
            `ALU_BGE: result = ($signed(op1)>=$signed(op2));
            `ALU_BLTU: result = (op1<op2);
            `ALU_BGEU: result = (op1>=op2);
        endcase
    end
endmodule