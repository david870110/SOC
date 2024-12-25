module dma
#(
    parameter pDATA_WIDTH = 32
)
(
    input [pDATA_WIDTH-1:0] mul_a,
    input [pDATA_WIDTH-1:0] mul_b,
    input acc_on,
    input cal,
    input clk,
    input rst_n,
    input last,
    output [pDATA_WIDTH-1:0] result
);

    input   clk,
    input   rst,

    // these signals go directly to the IO pins
    // output  sdram_clk,
    output  sdram_cle,
    output  sdram_cs,
    output  sdram_cas,
    output  sdram_ras,
    output  sdram_we,
    output  sdram_dqm,
    output  [1:0]  sdram_ba,
    output  [12:0] sdram_a,
    // Jiin: split dq into dqi (input) dqo (output)
    // inout [7:0] sdram_dq,
    input   [31:0] sdram_dqi,
    output  [31:0] sdram_dqo,

    // User interface
    // Note: we want to remap addr (see below)
    // input [22:0] addr,       // address to read/write
    input   [22:0] user_addr,   // the address will be remap to addr later
    
    input   rw,                 // 1 = write, 0 = read
    input   [31:0] data_in,     // data from a read
    output  [31:0] data_out,    // data for a write
    output  busy,               // controller is busy when high
    input   in_valid,           // pulse high to initiate a read/write
    output  out_valid           // pulses high when data from read is valid
    
    always@(posedge clk or negedge rst_n)
    begin

    end
endmodule