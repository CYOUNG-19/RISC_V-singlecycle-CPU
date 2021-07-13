`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/10 08:55:10
// Design Name: 
// Module Name: id
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


module id(

    input             rst_n,
    input [31:0]      inst_i,
    
    // �����regfile
    output reg [4:0]  reg1_addr_o,
    output reg [4:0]  reg2_addr_o,
    output reg [4:0]  wd_o,
    
    // ��ֵ�����ź�
    output reg [1:0]  branch_o,       // pc
    output reg  jump_o,         // pc
    output reg [2:0] memto_reg_o,   // ALU to Reg
    output reg  reg_wr_o,       // Reg
    output reg  mem_wr_o,       // Mem
    output reg  alu_asrc_o,     // Reg to ALU
    output reg muxpc_busa_o,    
    
    // ��ֵ�����ź�
    output reg [1:0]  alu_bsrc_o,   // imm and Reg to ALU
    output reg [2:0]  ext_op_o,     // imm
    output reg [5:0]  alu_ctr_o,     // ALU
    output reg [1:0]  mux_store_o   

    );
    
    wire [6:0] op  = inst_i[6:0];            //��������
    wire [2:0] f3 = inst_i[14:12];          //�������㷽ʽ
    wire [6:0] f7 = inst_i[31:25];
        
    always @ (*) begin
        if(~rst_n) begin    // ��������
            wd_o <= 0;
            reg1_addr_o <= 0;
            reg2_addr_o <= 0;
        end
        else begin      // ����
            wd_o <= inst_i[11:7];                     // д�Ĵ�����ַ
            reg1_addr_o <= inst_i[19:15];             // ���Ĵ��� A ��ַ
            reg2_addr_o <= inst_i[24:20];             // ���Ĵ��� B ��ַ
            
            // ��ֵ�����ź�
            branch_o[1]<=(op[6]& op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2])
                          | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[0]);
            branch_o[0]<=(op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2])
                          | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[0]);    //B-type
                              
            jump_o<=(op[6] & op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0])
                     | (op[6] & op[5] & ~op[4] & ~op[3] & op[2] & op[1] & op[0]);            // J-type
                     
            memto_reg_o[2]<= ~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2];
            memto_reg_o[1]<= ~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & ~f3[1];
            memto_reg_o[0]<= (~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[1])
                              | (~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[0]);    // Load

            reg_wr_o<= (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0])           // R - type
                         | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0])      // I - type - ALU
                         | (~op[6] & op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0])        // lui
                         | (~op[6] & ~op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0])
                         | (~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0])     // Load
                         | (op[6] & op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0]);        // J - type
            
            mem_wr_o<= ~op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];  // Store
            alu_asrc_o<= (op[6] & op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0])
                          | (~op[6] & ~op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0])
                          | (op[6] & op[5] & ~op[4] & ~op[3] & op[2] & op[1] & op[0]);  // J-type
                          
            muxpc_busa_o<= op[6] & op[5] & ~op[4] & ~op[3] & op[2] & op[1] & op[0];
            mux_store_o[1] = ~op[6]&op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0] & f3[0];
            mux_store_o[0] = ~op[6]&op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0] & ~f3[1];
            
            // ��ֵ�����ź�
            alu_bsrc_o[1]<= (~op[6] & ~op[5] & op[4]&~op[3] & ~op[2] & op[1] & op[0])   // I-type-ALU
                           | (~op[6]&op[5]&op[4]&~op[3]&op[2]&op[1]&op[0])              // lui
                           | (~op[6]&~op[5]&op[4]&~op[3]&op[2]&op[1]&op[0])             // auipc
                           | (~op[6]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0])           // Load
                           | (~op[6]&op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0]);           // Store
            alu_bsrc_o[0]<= (op[6] & op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0])    
                           | (op[6] & op[5] & ~op[4] & ~op[3] & op[2] & op[1] & op[0]); // J-type
            
            ext_op_o[2]<= op[6] & op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0];   // J - type
            ext_op_o[1]<= (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0])        // B - type
                           | (~op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0]);   // Store
            ext_op_o[0]<= (~op[6] & op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0])         // lui
                           | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0])     // B - type
                           | (~op[6] & ~op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0]);
           
           alu_ctr_o[5]<= (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & f7[5])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & f7[5])
                       | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[0]);
           alu_ctr_o[4]<= (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & ~f7[5])
                       | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1] & f3[0])
                       | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & ~f3[1] & f3[0])
                       | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & ~f3[0])
                       | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & ~f7[5])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1] & f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & ~f3[1] & f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & ~f3[0]);
           alu_ctr_o[3]<= (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & ~f7[5])
                       | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & ~f3[1] & f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & ~f3[1] & ~f3[0] & f7[5])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & ~f7[5])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & ~f3[1] & f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0])
                       | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2])
                       | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[1] & f3[0]);
           alu_ctr_o[2]<= (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & ~f7[5])
                       | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[1] & f3[0] & ~f7[5])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1])
                       | (~op[6] & op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0]);
           alu_ctr_o[1]<= (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & f3[1])
                       | (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1] & ~f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1] & ~f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & f3[1])
                       | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & ~f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0]);
           alu_ctr_o[0]<= (~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & f3[1] & f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0] & ~f3[2] & f3[1] & f3[0])
                       | (op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0] & f3[2] & f3[1] & ~f3[0])
                       | (~op[6] & op[5] & op[4] & ~op[3] & op[2] & op[1] & op[0]);
        end
    end
endmodule
