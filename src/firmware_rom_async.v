/*
 * Temporary asynchronous instruction ROM for the current single-cycle CPU.
 * The CPU consumes inst combinationally, while the generated Gowin pROM is a
 * clocked B-SRAM read port. Use this until the IF stage of the pipeline owns
 * the pROM read latency.
 */
module firmware_rom_async(
    input  wire [31:0] addr,
    output wire [31:0] data
);
    // Current firmware is well below 2 KiB; 512 words keeps LUT usage under
    // the GW2A device limit while the CPU still has a byte-addressed 2 KiB
    // instruction window (0x0000..0x07ff).
    reg [31:0] mem [0:511];

    initial begin
        $readmemh("firmware/build/firmware.hex", mem);
    end

    assign data = mem[addr[10:2]];
endmodule
