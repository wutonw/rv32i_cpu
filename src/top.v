module top(
    input wire raw_rst_n,
    input wire clk,
    output wire led_fail,
    output wire led_pass
);
    wire rst_n;
    wire [31:0] inst_addr;
    wire [31:0] inst;
    wire [9:0] prom_addr;
    wire prom_ce;

    // Mechanical reset input is active-low; debounce produces a stable
    // active-low reset for the CPU.
    debounce u_debounce(
        .clk    (clk),
        .key_in (raw_rst_n),
        .key_out(rst_n)
    );

    // The CPU uses byte addresses.  The pROM stores 32-bit instruction words,
    // so discard the two always-zero byte-offset bits.
    assign prom_addr = inst_addr[11:2];

    Gowin_pROM u_instruction_rom(
        .dout  (inst),
        .clk   (clk),
        .oce   (1'b1),
        .ce    (prom_ce),
        .reset (~rst_n),
        .ad    (prom_addr)
    );
    wire [31:0] pc;
    cpu_core u_cpu_core(
        .clk      (clk),
        .rst_n    (rst_n),
        .pc (pc),
        .inst     (inst),
        .inst_addr(inst_addr),
        .prom_ce  (prom_ce)
    );

    // Status LEDs are reserved for a later firmware/signature hookup.
    assign led_pass = ^pc[2];
    assign led_fail = ~^pc[2];
endmodule
