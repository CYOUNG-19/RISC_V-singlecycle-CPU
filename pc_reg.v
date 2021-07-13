`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/10 09:21:08
// Design Name: 
// Module Name: pc_reg
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


module pc_reg(
    input              clk,
    input              rst_n,
    input [31:0]       next_pc,

    output reg [31:0]  cur_pc,
    output reg         ce
    );

    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n)
            ce <= 1'b0;
        else
            ce <= 1'b1;      
    end

    always @ (posedge clk) begin
        if(~ce)
            cur_pc <= 32'b0;
        else
            cur_pc <= next_pc;
    end    
endmodule
