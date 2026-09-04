`include "define.vh"
module decoder(
    input wire [31:0] inst,
    output reg wr_en,
    output reg illegal_inst,

    output reg [1:0] alu_src_op1,//00:rs1,01:0,10:pc
    output reg alu_src_op2,//0:rs2,1:imm
    output reg ext_u,//0:ext,1:u_ext
    output reg [1:0] ram_size,//00:B, 01:H, 10:W
    output reg ram_we,
    output reg [1:0] wb_sel,//00:alu, 01:ram, 10:pc+4, 11:csr_r_data
    output reg branch,
    output reg jump,
    output reg jump_reg,
    output reg is_load,

    output reg decode_trap_enter,
    output reg trap_exit,
    output reg csr_we,

    output wire [4:0] rs1_addr,
    output wire [4:0] rs2_addr,
    output wire [4:0] rd_addr,
    output wire [11:0] csr_addr,

    output reg [3:0] alu_op
);

    wire [6:0] opcode = inst[6:0];
    wire [6:0] funct7 = inst[31:25];
    wire [2:0] funct3 = inst[14:12];

    assign rs1_addr = inst[19:15];
    assign rs2_addr = inst[24:20];
    assign rd_addr = inst[11:7];
    assign csr_addr = inst[31:20];

    reg csr_valid;

    always @(*)begin
        alu_op=`ALU_ADD; 
        wr_en=0;
        illegal_inst=0;
        alu_src_op1=0;
        alu_src_op2=0;
        ext_u=0;
        ram_size=0;
        ram_we=0;
        wb_sel=0;
        branch=0;
        jump=0;
        jump_reg=0;
        is_load=0;
        decode_trap_enter=0;
        trap_exit=0;
        csr_we=0;
        case(opcode)
            `OP_R_TYPE:begin
                wr_en=1;
                if(funct7 == 7'b0)begin
                    case(funct3)
                        3'b000: alu_op = `ALU_ADD;
                        3'b001: alu_op = `ALU_SLL;
                        3'b010: alu_op = `ALU_SLT;
                        3'b011: alu_op = `ALU_SLTU;
                        3'b100: alu_op = `ALU_XOR;
                        3'b101: alu_op = `ALU_SRL;
                        3'b110: alu_op = `ALU_OR;
                        3'b111: alu_op = `ALU_AND;
                    endcase
                end else if(funct7 == 7'b0100000 && (funct3==3'b0 ||funct3==3'b101))begin
                    alu_op = (funct3 == 0)? `ALU_SUB : `ALU_SRA;
                end else begin
                    wr_en = 0;
                    illegal_inst = 1;
                end
            end
            `OP_I_TYPE:begin
                wr_en=1;
                alu_src_op2=1;
                case(funct3)
                    3'b000: alu_op = `ALU_ADD;
                    3'b010: alu_op = `ALU_SLT;
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                    default:begin
                        if(funct3 == 3'b001 && funct7 == 7'b0)begin
                            alu_op = `ALU_SLL;
                        end else if (funct3 == 3'b101 && (funct7 == 7'b0 || funct7 == 7'b0100000))begin
                            alu_op = (funct7[5])? `ALU_SRA : `ALU_SRL;
                        end else begin
                            wr_en = 0;
                            illegal_inst = 1;
                        end
                    end
                endcase
            end
            `OP_LOAD:begin
                if (funct3 != 3'b011 && funct3 != 3'b110 && funct3 != 3'b111 )begin
                    is_load=1;
                    wr_en=1;
                    ext_u=funct3[2];
                    ram_size=funct3[1:0];
                    alu_src_op2=1;
                    alu_op = `ALU_ADD;
                    wb_sel = 1;
                end else begin
                    illegal_inst = 1;
                end
            end
            `OP_STORE:begin
                if (funct3 == 3'b0 || funct3 == 3'b001 || funct3 == 3'b010)begin
                    ram_we = 1;
                    alu_src_op2 = 1;
                    alu_op = `ALU_ADD;
                    ram_size=funct3[1:0];
                end else begin
                    illegal_inst = 1;
                end
            end
            `OP_BRANCH:begin
                branch=1;
                case(funct3)
                    3'b000: alu_op = `ALU_BEQ;
                    3'b001: alu_op = `ALU_BNE;
                    3'b100: alu_op = `ALU_BLT;
                    3'b101: alu_op = `ALU_BGE;
                    3'b110: alu_op = `ALU_BLTU;
                    3'b111: alu_op = `ALU_BGEU;
                    default:begin
                        branch = 0;
                        illegal_inst = 1;
                    end
                endcase
            end
            `OP_LUI:begin
                alu_src_op1 = 2'b01;
                alu_src_op2 = 1;
                wr_en = 1;
                alu_op = `ALU_ADD;
            end
            `OP_AUIPC:begin
                alu_src_op1 = 2'b10;
                alu_src_op2 = 1;
                wr_en = 1;
                alu_op = `ALU_ADD;
            end
            `OP_JAL:begin
                wr_en = 1;
                jump=1;
                wb_sel = 2'b10;
            end
            `OP_JALR:begin
                if (funct3 == 3'b0)begin
                    wr_en = 1;
                    wb_sel = 2'b10;
                    alu_src_op2 = 1;
                    jump_reg = 1;
                    alu_op =`ALU_ADD;
                end else begin
                    illegal_inst = 1;
                end
            end
            `OP_SYSTEM:begin
                if(funct3 == 3'b0 && rs1_addr == 5'b0 && rd_addr == 5'b0)begin
                    case(inst[31:20])
                        //ecall
                        12'h000:begin
                            decode_trap_enter = 1;
                        end
                        //ebreak
                        12'h001:begin
                            decode_trap_enter = 1;
                        end
                        //mert
                        12'h302:begin
                            trap_exit = 1;
                        end
                        default: illegal_inst = 1;
                    endcase
                end else begin
                    if(funct3 != 3'b100 && funct3 != 3'b0 && csr_valid)begin
                        //csr
                        csr_we = 1;
                        wr_en = 1;
                        wb_sel = 2'b11;
                    end else begin
                        illegal_inst = 1;
                    end
                end
            end
            default: illegal_inst = 1;
        endcase
    end

    always @(*)begin
        csr_valid = 0;
        if(csr_addr == 12'h300 || csr_addr == 12'h304 || csr_addr == 12'h305 || csr_addr == 12'h341 || csr_addr == 12'h342)begin
            csr_valid = 1;
        end

    end

endmodule