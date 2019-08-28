`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:09:32 10/09/2018 
// Design Name: 
// Module Name:    lpset7 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lpset7(
    input clock,
    input start,
    input data,
    output done,
    output [95:0] fec
    );
	 
		//temp regs for shifting and checking
		reg [95:0] res;
		reg [8:0] count;
		reg over;
		reg three = 0;
		reg two =0;
		reg one =0;
		reg pbit0;
		reg pbit1;
		
		//assign outputs
		assign done = (count == 96);
		assign fec = res;
		
		//cycling
		always @(posedge clock) begin
			//reset to initial values
			if (start) begin
				res <= 96'h000000000000000000000000;
				over <= 0;
				count <= 0;
			end
			else begin 
				//shift past data
				three <= data;
				two <=  three; 
				one <= two; 
				//calculate parity bits
				pbit1 = data ^ one ^ two;
				pbit0 = data ^ three ^ two ^ one;
				//shifting!!!
				res[95:0] = {res[93:0], pbit1, pbit0};
				count = count + 2;
			end
		end	
endmodule
