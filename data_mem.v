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
    input [31:0]       addr,      // д���ַ
    input [31:0]       data_in,   // д������
    input              mem_wr,    // дʹ��
    output reg [31:0] data_out  // д������
);

reg [31:0] mem_r [0:255];

integer i;
initial
begin
for(i=0;i<255;i=i+1)
	mem_r[i] = 0;
end
// ��ʼ���洢������ �������ʹ�þ���·������Ȼ������ֵ
initial $readmemh ("data_rom.data", mem_r);


always @ (posedge clk or negedge rst_n) begin      //д��洢��
    if(rst_n) begin
      //  if((addr != 32'b0) && (mem_wr))
	  if((mem_wr))
        // ÿһ�� 32 λ���ݵ�ַ��Ҫռ�� 4 ����ַλ��ָ���ַ ��ҪΪ 4 �ı��������Խ�ָ���ַ������λ����֤��ַ����ȷ��
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

always @ (*) begin                                 //�洢����������
    //if(~rst_n || addr == 32'b0)
	if(~rst_n )
        data_out <= 32'b0;
    else
        // ÿһ�� 32 λ���ݵ�ַ��Ҫռ�� 4 ����ַλ��ָ���ַ ��ҪΪ 4 �ı��������Խ�ָ���ַ������λ����֤��ַ����ȷ��
        data_out <= mem_r[addr[9:2]];
end
endmodule

