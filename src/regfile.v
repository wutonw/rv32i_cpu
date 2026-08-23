module regfile(
    input wire clk,
    input wire rst_n,

    //write port
    input wire wr_en,
    input wire wr_addr,
    input wire wr_data,

    //read port 1
    input wire rs1_addr,
    output wire rs1_data,

    //read port 2
    input wire rs2_addr,
    output wire rs2_data,
);

    reg [31:0] rf [0:31];//32 bits rf

    integer i;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(i=0;i<32;i=i+1)begin
                rf[i]<=0;
            end
        end else if (wr_en && wr_addr!=0) begin
            //x0=0
            rf[wr_addr]<=wr_data;
        end
    end

    assign rs1_data = (rs1_addr==0)? 32'b0 : rf[rs1_addr];
    assign rs2_data = (rs2_addr==0)? 32'b0 : rf[rs2_addr];

endmodule