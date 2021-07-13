`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/11 10:59:37
// Design Name: 
// Module Name: alu
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


module alu(
    
    input [31:0]         regA_i,
    input [31:0]         regB_i,
    
    input                sub_ctr_i,
    input                sig_ctr_i,
    input [3:0]          op_ctr_i,
    
    output   zf, // ���־
    output   sf, // ���ű�־
    output   cf, // ��λ/��λ��־
    output   of, // �����־
    
    output reg           cout,
    output reg [31:0]    result_o
    
    );

reg [31:0] result;
reg [31:0] regB_ii;

    
always @ (*) begin
    if (sub_ctr_i) begin    // ������չ
        regB_ii <= ~regB_i;
    end       
    else begin
        regB_ii <= regB_i;
    end
    {cout, result} <= regA_i + regB_ii + sub_ctr_i;
    case(op_ctr_i)
        4'b0000: begin
            result_o <= result;
        end
        4'b0011: begin
            if (sig_ctr_i) begin    // �����������Ƚ�С���� 1
                result_o <= {31'b0, (of ^ sf)};     // ����չ
            end
            else begin
                if(regA_i < regB_i)
                    result_o <= 32'b1;
                else
                    result_o <= 32'b0;

                // result_o <= {31'b0, (sub_ctr_i ^ cf)};      // ����չ    
            end
        end
        4'b1100: begin
              result_o <= {31'b0, ~(of ^ sf)};     // ����չ
//            if(result[31])
//                result_o <= 32'b1;  //  ���ڵ���
//            else
//                result_o <= 32'b0; // С��
        end
        4'b1110: begin
            if(regA_i >=  regB_i)
                result_o <= 32'b1;
            else
                result_o <= 32'b0;

            //result_o <= {31'b0, ~(sub_ctr_i ^ cf)};  // �޷���
        end  
        4'b0001: begin      // orѡ��"��λ��"������
            result_o <= regA_i | regB_i;
        end
        4'b0101: begin      //andѡ��"��λ��"������
            result_o <= regA_i & regB_i;
        end
        4'b0100: begin      //xorѡ��"��λ���"������
            result_o <= (~regA_i & regB_i)|(regA_i & ~regB_i);
        end
        4'b0010: begin      // srcBѡ������� B ֱ�����
            result_o <= regB_i;
        end
        4'b0110: begin      //sll�߼�����
            result_o <= regA_i << regB_i[4:0];
        end
        4'b0111: begin      //srl�߼�����
            result_o <= regA_i >> regB_i[4:0];
        end
        4'b1000: begin      //sra��������
            result_o <= ({32{regA_i[31]}}<<(6'd32-{1'b0,regB_i[4:0]}))|regA_i>>regB_i[4:0];
        end
    endcase
end

assign zf = (result == 32'b0 ? 1'b1 : 1'b0); // ���־
assign sf = result[31];   // ���ű�־
assign cf = (sub_ctr_i ? ~cout : cout); // ��λ/��λ��־

// �� X �� Y' �����λ��ͬ�Ҳ�ͬ�ڽ�� F �����λʱ������� of = 1 ���� of = 0
assign of = ((regA_i[31] == regB_ii[31]) && (regA_i[31] != result[31]) ? 1'b1 : 1'b0 ); // �����־
endmodule
