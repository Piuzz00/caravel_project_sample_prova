`timescale 1ns / 1ps
module Sum_4_bits (
    input clk,
    input rst,
    input en,
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] S
);

reg [3:0] A_FF, B_FF;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        A_FF <= {4{1'b0}};
        B_FF <= {4{1'b0}};
        S    <= {4{1'b0}};
    end else begin
        if (en) begin
            A_FF <= A;
            B_FF <= B;
        end
        // registered result is always updated from the registered operands
        S <= A_FF + B_FF;
    end
end

endmodule
