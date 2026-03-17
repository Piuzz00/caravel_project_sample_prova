// SPDX-License-Identifier: Apache-2.0
`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * Example project connected to logic analyzer, wishbone bus
 * and IO pads.
 *
 * Modified version: instead of a counter, performs a
 * 4-bit addition between two operands.
 *
 *-------------------------------------------------------------
 */

module Prova_OpenLane #(
    parameter BITS = 4
)(
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [2*BITS-1:0] io_in,
    output [BITS-1:0] io_out,
    output [BITS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

    wire clk;
    wire rst;

    wire [BITS-1:0] rdata;
    wire [2*BITS-1:0] wdata;
    wire [BITS-1:0] S;

    wire valid;
    wire [3:0] wstrb;
    wire [BITS-1:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i;
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = {{(32-BITS){1'b0}}, rdata};
    assign wdata = wbs_dat_i[2*BITS-1:0];
    
    // IO
    assign io_out = S;
    assign io_oeb = {(BITS){rst}};

    // IRQ
    assign irq = 3'b000;

    // LA
    assign la_data_out = {{(128-BITS){1'b0}}, S};
    assign la_write = ~la_oenb[63:64-BITS] & ~{BITS{valid}};
    assign clk = (~la_oenb[64]) ? la_data_in[64] : wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65] : wb_rst_i;

    Sum_4_bits #(
        .BITS(BITS)
    ) Sum_4_bits(
        .clk(clk),
        .reset(rst),
        .ready(wbs_ack_o),
        .valid(valid),
        .rdata(rdata),
        .wdata(wdata),
        .wstrb(wstrb),
        .la_write(la_write),
        .la_input(la_data_in[63:64-BITS]),
        .S(S)
    );

endmodule

module Sum_4_bits #(
    parameter BITS = 4
)(
    input clk,
    input reset,
    input valid,
    input [3:0] wstrb,
    input [2*BITS-1:0] wdata,
    input [BITS-1:0] la_write,
    input [BITS-1:0] la_input,
    output reg ready,
    output reg [BITS-1:0] rdata,
    output reg [BITS-1:0] S
);

reg [3:0] A_FF, B_FF;

wire [3:0] A;
wire [3:0] B;

assign A = wdata[3:0];
assign B = wdata[7:4];

always @(posedge clk) begin
    if (reset) begin
        A_FF <= 4'b0000;
        B_FF <= 4'b0000;
        S    <= 4'b0000;
        ready <= 1'b0;
    end else begin
        ready <= 1'b0;

        if (valid & wstrb[0] & wstrb[1]) begin
    	     A_FF <= A;
    	     B_FF <= B;
	end

        if (~|la_write) begin
            S <= A_FF + B_FF;
        end

        if (valid && !ready) begin
            ready <= 1'b1;
            rdata <= S;
        end else if (|la_write) begin
            S <= la_write & la_input;
        end
    end
end

endmodule

`default_nettype wire
