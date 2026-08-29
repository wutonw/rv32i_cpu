`ifndef RV32I_DEFINE_VH
`define RV32I_DEFINE_VH

// Opcode 宏定义 (标准 RISC-V RV32I 定义)
`define OP_SYSTEM   7'b1110011
`define OP_R_TYPE   7'b0110011  // ADD, SUB, AND, OR 等
`define OP_I_TYPE   7'b0010011  // ADDI, ANDI 等
`define OP_LOAD     7'b0000011  // LW 等
`define OP_STORE    7'b0100011  // SW 等
`define OP_BRANCH   7'b1100011  // BEQ, BNE 等
`define OP_LUI      7'b0110111  // LUI
`define OP_AUIPC    7'b0010111  // AUIPC
`define OP_JAL      7'b1101111  // JAL
`define OP_JALR     7'b1100111

//ALU operation Encoding
`define ALU_ADD  4'b0000  // add
`define ALU_SUB  4'b0001  // sub
`define ALU_SLL  4'b0010  // Shift Left Logical
`define ALU_SLT  4'b0011  // 有符号小于置1 (Set Less Than)
`define ALU_SLTU 4'b0100  // 无符号小于置1 (Set Less Than Unsigned)
`define ALU_XOR  4'b0101  // 按位异或
`define ALU_SRL  4'b0110  // 逻辑右移 (Shift Right Logical)
`define ALU_SRA  4'b0111  // 算术右移 (Shift Right Arithmetic)
`define ALU_OR   4'b1000  // 按位或
`define ALU_AND  4'b1001  // 按位与

`define ALU_BEQ  4'b1010  // ==
`define ALU_BNE  4'b1011  // !=
`define ALU_BLT  4'b1100  // < (有符号)
`define ALU_BGE  4'b1101  // >= (有符号)
`define ALU_BLTU 4'b1110  // < (无符号)
`define ALU_BGEU 4'b1111  // >= (无符号)

`endif