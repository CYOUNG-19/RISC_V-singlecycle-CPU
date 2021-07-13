`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/12 16:06:27
// Design Name: 
// Module Name: reg_file
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


module reg_file(
    input              rst_n,
    input              clk,

    input [4:0]        rw,      // д���ַ
    input [31:0]       bus_w,   // д������
    input              reg_wr,  // дʹ��

    input [4:0]        ra,      // ����ַ
    //input              re1,     // ��ˮ���Ż�
    output reg [31:0] bus_a,   // ��������

    input [4:0]        rb,      // ����ַ
    //input              re2,     //��ˮ���Ż�
    output reg [31:0] bus_b    // ������
);

    reg [31:0] mem_r [0:31];

initial
begin
$monitor("r[22]: 0x%8X", mem_r[22]);
end

initial
begin
$monitor("r[23]: 0x%8X", mem_r[23]);
end 
    
integer i;    
initial begin
for(i=0;i<32;i=i+1)
	mem_r[i] = 32'd0;
//    mem_r[5'b00001] = 32'b0000_0000_0000_0000_0000_0000_0000_0100;
//    mem_r[5'b00010] = 32'b0000_0000_0000_0000_1111_0000_0000_0000;
//    mem_r[5'b00001] = 32'b1111_1111_1111_1111_1111_1111_1111_1010;
//    mem_r[5'b00010] = 32'b1111_1111_1111_1111_1111_1111_1111_1010;
end

    
always @ (posedge clk or negedge rst_n) begin      //д��Ĵ���
    if(rst_n) begin
        // �˴�����Ϊ����д�� 00000 ��ַ��
        if((rw != 5'b0) && (reg_wr))
            mem_r[rw] <= bus_w;
    end
end

always @ (*) begin                                 //�Ӷ˿�1��������
    if(~rst_n)
        bus_a <= 32'b0;
    
    // ���ɶ� 0 ��ַ
    else if(ra == 5'b0)
        bus_a <= 32'b0;
//    else if((ra == rw) && re1 && reg_wr)        //���д��ĵ�ַ��Ҫ�����ĵ�ַ��ͬ
//        bus_a <= bus_w;                           //��ֱ�ӽ�д�����ݶ���
//    else if(re1)
//        bus_a <= mem_r[ra];
    else
        bus_a <= mem_r[ra];
//        bus_a <= 32'b0;
    end

always @ (*) begin                                 //�Ӷ˿�2��������
    if(~rst_n)
        bus_b <= 32'b0;
    else if(rb == 5'b0)
        bus_b <= 32'b0;
//    else if((rb == rw) && re2 && reg_wr)
//        bus_b <= bus_w;
//    else if(re2)
//        bus_b <= mem_r[rb];
    else
        bus_b <= mem_r[rb];
//        bus_b <= 32'b0;
    end

endmodule
