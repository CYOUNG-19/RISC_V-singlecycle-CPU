`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/14 09:34:13
// Design Name: 
// Module Name: test_cup_top
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


module test_cup_top;

    reg         clk;
    reg         rst_n;
    
    wire [31:0]    inst;    
    wire [31:0]    cur_pc;
    wire [31:0]    next_pc;
    
    wire [4:0]  rw_addr;
    wire [4:0]  ra_addr;
    wire [4:0]  rb_addr; 
    
    wire [31:0]      imm;
    wire             zero;
    wire             ce;
        
    wire [31:0]      bus_w;   
    wire [31:0]      bus_a;          
    wire [31:0]      bus_b;     
    wire [31:0]      bus_b_o;
    wire [31:0]      bus_a_o;
    wire [31:0]      bus_bi;   // alu_bsrc result.
    wire [31:0]      bus_ai;   // alu_asrc result. 
    wire [31:0]      bus_wo;   // mem_to_reg result.      
    wire [31:0]      data_out; // mem data out.

    // ��ֵ�����ź�
    wire  jump;         // pc
    wire  reg_wr;       // Reg
    wire  mem_wr;       // Mem
    wire  alu_asrc;     // Reg to ALU
    wire  muxpc_busa;
    
    // ��ֵ�����ź�
    wire [1:0] alu_bsrc;   // imm and Reg to ALU
    wire [2:0] ext_op;     // imm
    wire [5:0] alu_ctr;    // ALU
    wire [1:0] mux_store_o; // ���ݴ洢�������·ѡ��������
    wire [1:0] branch;      // pc
    wire [2:0] mem_to_reg;   // ALU to Reg


    initial begin
        clk = 0;
        rst_n = 0;
        
        #50
        rst_n = 1'b1;
        
    end
    always #50 clk = ~clk;

    // �Ĵ���
    reg_file reg_file0(
        .rst_n(rst_n),
        .clk(clk),
        
        .rw(rw_addr),
        .bus_w(bus_wo),
        .reg_wr(reg_wr),
        
        .ra(ra_addr),
        .bus_a(bus_a),
        
        .rb(rb_addr),
        .bus_b(bus_b)
        );
        
    // ALU
    alu_top alu_top0(
        .regA_i(bus_ai), 
        .regB_i(bus_bi), 
        .alu_ctr(alu_ctr), 
        .res_o(bus_w), 
        .zero(zero)
        );
        
    // ��չ��
    ie ie0(
        .instr(inst),
        .ext_op(ext_op),
        .imm(imm)
        );
    
    // �µ�ַ�߼�
    next_pc next_pc0(
        .pcOrbusa(bus_a_o),
        .imm(imm),
        .branch(branch),
        .result_o(bus_w[0]),
        .zero(zero),
        .jump(jump),
        .next_pc(next_pc)
        );
            
    // ָ��洢��
    inst_rom inst_rom0(
        .ce(ce),
        .addr(cur_pc),
        .inst(inst)
        );
            
    // ���������
    pc_reg pc_reg0(
        .clk(clk),
        .rst_n(rst_n),
                
        .next_pc(next_pc),
        .cur_pc(cur_pc),
        .ce(ce)
        );
    
    // mux from bus_b and imm and 4. send bus_bi to alu regB_i.
    mux_alu_bsrc mux_alu_bsrc0(
        .alu_bsrc(alu_bsrc),
        .bus_b(bus_b),
        .imm(imm),
            
        .bus_bo(bus_bi)
        );
        
    // mus from bus_a and pc to regA_i
    mux_alu_asrc mux_alu_asrc0(
        .alu_asrc(alu_asrc),
        .bus_a(bus_a),
        .pc(cur_pc),
            
        .bus_ao(bus_ai)
        );
        
    // �洢��
    data_mem data_mem0(
        .rst_n(rst_n),
        .clk(clk),
        
        .addr(bus_w),      // д���ַ
        .data_in(bus_b_o),   // д������
        .mem_wr(mem_wr),    // дʹ��
        .mux_store (mux_store_o),    
        .data_out(data_out)  // д������
    );
        
    id id0(
        .rst_n(rst_n),
        .inst_i(inst),
        
        .reg1_addr_o(ra_addr),
        .reg2_addr_o(rb_addr),
        .wd_o(rw_addr),  
            
        .branch_o(branch),       // pc
        .jump_o(jump),         // pc
        .memto_reg_o(mem_to_reg),   // ALU to Reg
        .reg_wr_o(reg_wr),       // Reg
        .mem_wr_o(mem_wr),       // Mem
        .alu_asrc_o(alu_asrc),     // Reg to ALU
        .muxpc_busa_o(muxpc_busa),
            
        // ��ֵ�����ź�
        .alu_bsrc_o(alu_bsrc),   // imm and Reg to ALU
        .ext_op_o(ext_op),     // imm
        .alu_ctr_o(alu_ctr),     // ALU
        .mux_store_o(mux_store_o)
        );
        
        

    // �ֽڡ����ֽڴ���ָ��
	mux_store mux_store0(
		.bus_b(bus_b),                // ��·ѡ��������
		.mux_store(mux_store_o),        // ��·ѡ��������
		  
		.bus_b_o(bus_b_o)             // ��·ѡ������� 
		);
		
	// �ֽڡ����ֽ�ȡ��ָ��
	mux_memto_reg mux_memto_reg0(
        .result(bus_w),             // ALU ������
        .mem_data(data_out),        // ���ݴ洢��
        .memto_reg(mem_to_reg),     // ��·ѡ����ѡ��
        .addr(bus_w),      // д���ַ    
        .bus_w_o(bus_wo)            // ��·ѡ�������
        );
        
    // �µ�ַָ��洢����˿�ѡ����
	mux_PcOrBusA mux_PcOrBusA0(
        .bus_a(bus_a),
        .pc(cur_pc),
        .mux_pcBusa(muxpc_busa),
            
        .bus_a_o(bus_a_o)
        );

endmodule
