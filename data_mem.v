`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/11 14:45:59
// Design Name: 
// Module Name: data_mem
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


module data_mem(
    input              rst_n,
    input              clk,
	input [1:0]			mux_store,
    input [31:0]       addr,      // 写入地址
    input [31:0]       data_in,   // 写入数据
    input              mem_wr,    // 写使能
    output reg [31:0] data_out  // 写出数据
);

reg [31:0] mem_r [0:255];

integer i;
initial
begin
for(i=0;i<255;i=i+1)
	mem_r[i] = 0;
end
// 初始化存储器数据 这里必须使用绝对路径，不然读不到值
initial $readmemh ("data_rom.data", mem_r);


always @ (posedge clk or negedge rst_n) begin      //写入存储器
    if(rst_n) begin
      //  if((addr != 32'b0) && (mem_wr))
	  if((mem_wr))
        // 每一条 32 位数据地址都要占用 4 个地址位，指令地址 都要为 4 的倍数，可以将指令地址左移两位来保证地址的正确性
			begin
  			if(mux_store == 2'b11)
				begin
				if(addr[1:0] == 2'b10)
					mem_r[addr[9:2]][31:16] <= data_in[15:0];
				else
					mem_r[addr[9:2]][15:0] <= data_in[15:0];
				end
			else if(mux_store == 2'b01)
				begin
					if(addr[1:0] == 0)
						mem_r[addr[9:2]][7:0] <= data_in[7:0];
					else if(addr[1:0] == 1)
						mem_r[addr[9:2]][15:8] <= data_in[7:0];
					else if(addr[1:0] == 2)
						mem_r[addr[9:2]][23:16] <= data_in[7:0];
					else if(addr[1:0] == 3)
						mem_r[addr[9:2]][31:24] <= data_in[7:0];
				end
			else 
				mem_r[addr[9:2]] <= data_in;
			end
    end
end

always @ (*) begin                                 //存储器读出数据
    //if(~rst_n || addr == 32'b0)
	if(~rst_n )
        data_out <= 32'b0;
    else
        // 每一条 32 位数据地址都要占用 4 个地址位，指令地址 都要为 4 的倍数，可以将指令地址左移两位来保证地址的正确性
        data_out <= mem_r[addr[9:2]];
end
endmodule

