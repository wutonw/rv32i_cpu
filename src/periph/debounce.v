module debounce(
    input clk,
    input key_in, //输入信号
    output reg key_out //输出信号（稳定）
);

    reg [19:0] count;//20ms延迟，27Mhz 1/50=540_000
    reg key_reg;//保存状态
    initial begin
        key_out = 1'b1;
        key_reg = 1'b1;
        count = 20'd0;
    end

    always @(posedge clk) begin
        key_reg<=key_in;
        if(key_in != key_reg)begin
            count <= 20'd0;
        end
        else if (count <20'd540_000)begin
            count <=count + 1'b1;
        end
        else begin
            key_out <= key_in;
        end 
    end

endmodule