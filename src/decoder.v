module decoder(
    input wire [31:0] inst,
    output reg wr_en,
    output reg alu_src,//0:rs2,1:imm
    output reg ext_u,//0:ext,1:u_ext
    output reg [1:0] ram_size,//00:B, 01:H, 10:W
    output reg ram_we,
    output reg [1:0] wb_sel,//00:alu, 01:ram

    output wire [4:0] rs1_addr,
    output wire [4:0] rs2_addr,
    output wire [4:0] rd_addr,

    output reg [3:0] alu_op
);
    wire [6:0] opcode = inst[6:0];
    wire [6:0] funct7 = inst[31:25];
    wire [2:0] funct3 = inst[14:12];

    assign rs1_addr = inst[19:15];
    assign rs2_addr = inst[24:20];
    assign rd_addr = inst[11:7];

    always @(*)begin
        wr_en=0;
        alu_src=0;
        ext_u=0;
        ram_size=0;
        ram_we=0;
        wb_sel=0;
        case(opcode)
            `OP_R_TYPE:begin
                wr_en=1;
                case(funct3)
                    3'b000: alu_op = (funct7[5]==1)? `ALU_SUB : `ALU_ADD;
                    3'b001: alu_op = `ALU_SLL;
                    3'b010: alu_op = `ALU_SLT;
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b101: alu_op = (funct7[5]==1)? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                endcase
            end
            `OP_I_TYPE:begin
                wr_en=1;
                alu_src=1;
                case(funct3)
                    3'b000: alu_op = `ALU_ADD;
                    3'b001: alu_op = `ALU_SLL;
                    3'b010: alu_op = `ALU_SLT;
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b101: alu_op = (funct7[5])? `ALU_SRA : `ALU_SRL;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                endcase
            end
            `OP_LOAD:begin
                wr_en=1;
                ext_u=funct3[2];
                ram_size=funct3[1:0];
                alu_src=1;
                alu_op = `ALU_ADD;
                wb_sel = 1;
            end

        endcase
    end
endmodule