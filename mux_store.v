`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/13 11:59:10
// Design Name: 
// Module Name: mux_store
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


module mux_store(
    input [31:0]	bus_b,
	input [1:0]		mux_store,

	output reg[31:0]	bus_b_o
    );
	
	always @ (*) begin
		case(mux_store)
			2'b00: begin  // ֱ�����
				bus_b_o <= bus_b;
			end
			2'b01: begin  // �з���ȡbus_b��8λ�����з�����չ
				bus_b_o <= {{24{bus_b[7]}}, bus_b[7:0]};
			end
			2'b11: begin  // �з���ȡbus_b��16λ�����з�����չ
				bus_b_o <= {{16{bus_b[15]}}, bus_b[15:0]};
			end
		endcase
	end
endmodule
