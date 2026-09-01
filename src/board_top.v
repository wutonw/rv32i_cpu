/*
 * Physical-board wrapper.
 *
 * The original top module remains the CPU core interface used by the
 * testbenches. This wrapper supplies an asynchronous instruction ROM and
 * latches the firmware signature into PASS/FAIL LED outputs.
 *
 * The current single-cycle CPU needs asynchronous instruction read. The
 * generated Gowin pROM is clocked and should be connected after the IF stage
 * of the planned pipeline is added.
 */
module board_top(
    input  wire clk,
    input  wire raw_rst_n,
    output wire led_pass,
    output wire led_fail
);
    localparam [31:0] SIGNATURE_ADDR = 32'h0000_7ff8;
    localparam [31:0] PASS_SIGNATURE = 32'h600d_cafe;

    wire [31:0] inst_addr;
    wire [31:0] inst;
    wire        ram_commit;
    wire [31:0] ram_commit_addr;
    wire [31:0] ram_commit_data;

    firmware_rom_async u_inst_rom (
        .addr  (inst_addr),
        .data  (inst)
    );

    top u_cpu (
        .clk             (clk),
        .raw_rst_n       (raw_rst_n),
        .inst            (inst),
        .inst_addr       (inst_addr),
        .ram_commit      (ram_commit),
        .ram_commit_addr (ram_commit_addr),
        .ram_commit_data (ram_commit_data)
    );

    reg pass_latched;
    reg fail_latched;

    always @(posedge clk or negedge raw_rst_n) begin
        if (!raw_rst_n) begin
            pass_latched <= 1'b1;
            fail_latched <= 1'b1;
        end else if (ram_commit &&
                     ram_commit_addr == SIGNATURE_ADDR) begin
            if (ram_commit_data == PASS_SIGNATURE)
                pass_latched <= 1'b0;
            else if (ram_commit_data[31:16] == 16'hdead)
                fail_latched <= 1'b0;
        end
    end

    assign led_pass = pass_latched;
    assign led_fail = fail_latched;
endmodule
