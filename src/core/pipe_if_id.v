module pipe_if_id(
    input wire clk,
    input wire rst_n,
    input wire if_id_flush,
    input wire stall,

    input wire [31:0] pc,
    input wire [31:0] inst,
    output wire [31:0] if_id_inst,
    output reg [31:0] if_id_pc,
    output reg if_id_valid
);

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            if_id_valid <= 1'b0;
        end else if (if_id_flush)begin
            if_id_valid <= 1'b0;
        end else if(!stall)begin
            if_id_pc <= pc;
            if_id_valid <= 1'b1;
        end
    end
    assign if_id_inst = inst;
endmodule
