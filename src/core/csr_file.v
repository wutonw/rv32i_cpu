module csr_file(
    input wire clk,
    input wire rst_n,

    input wire [11:0] csr_addr,
    input wire [31:0] csr_w_data,
    input wire csr_we,
    output reg [31:0] csr_r_data,

    input wire trap_enter,//1 pulse
    input wire [31:0] trap_pc,
    input wire [31:0] trap_cause,
    output wire [31:0] trap_vector,

    input wire trap_exit,
    output wire [31:0] mepc_out,

    output wire global_intr_en //mstatus.MIE
);

    reg [31:0] mepc;
    reg [31:0] mtvec;
    reg [31:0] mstatus;
    reg [31:0] mcause;
    reg [31:0] mie;

    assign mepc_out = mepc;
    assign trap_vector = mtvec;
    assign global_intr_en = mstatus[3];

    always @(*)begin
        case (csr_addr)
            12'h300: csr_r_data = mstatus;
            12'h304: csr_r_data = mie;
            12'h305: csr_r_data = mtvec;
            12'h341: csr_r_data = mepc;
            12'h342: csr_r_data = mcause;
            default: csr_r_data = 32'h0;
        endcase
    end

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            mstatus <= 0;
            mie <= 0;
            mcause <= 0;
            mepc <= 0;
            mtvec <= 0;
        end else begin
            if (trap_enter)begin
                mepc <= trap_pc;
                mcause <= trap_cause;
                mstatus[7] <= mstatus[3]; //MPIE <= MIE
                mstatus[3] <= 0;
            end else if(trap_exit) begin
                mstatus[3] <= mstatus[7];
                mstatus[7] <= 1'b1;
            end else if(csr_we) begin
                case (csr_addr)
                    12'h300: mstatus <= csr_w_data;
                    12'h304: mie <= csr_w_data;
                    12'h305: mtvec <= csr_w_data;
                    12'h341: mepc <= csr_w_data;
                    12'h342: mcause <= csr_w_data;
                    default: ;
                endcase
            end
        end
    end
endmodule