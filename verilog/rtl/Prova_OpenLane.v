`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2026 19:12:13
// Design Name: 
// Module Name: Prova_OpenLane
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Prova_OpenLane(
    input clk,
    input rst,
    input en,
    input [3:0] A,
    input [3:0] B,
    output [3:0] S
    );
    
Sum_4_bits example(
    .A(A),
    .B(B),
    .S(S),
    .clk(clk),
    .rst(rst),
    .en(en)
);

endmodule
