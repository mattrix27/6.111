`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:14:12 10/03/2018 
// Design Name: 
// Module Name:    lpset6 
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
module lpset6(
    input clock,
    input start,
    input data,
    output done,
    output [15:0] r
    );
	
	//temp regs for shifting and checking
	reg [15:0] res;
	reg [6:0] count;
	reg over;
	
	//assign outputs
	assign done = over;
	assign r = res;
	
	//cycling
	always @(posedge clock) begin
		//reset to initial values
		if (start) begin
			res <= 16'hFFFF;
			over <= 0;
			count <= 0;
		end
		
		//check it 48 bits have been processed
		else if (count == 47) begin 
			over = 1; //we done!
		end
		
		//more bits to be processed, start shifting!
		else begin
			res[0] <= res[15] ^ data; //generator polynomial
			res[1] <= res[0];
			res[2] <= res[1] ^ (res[15] ^ data); //generator polynomial
			res[3] <= res[2];
			res[4] <= res[3];
			res[5] <= res[4];
			res[6] <= res[5];
			res[7] <= res[6];
			res[8] <= res[7];
			res[9] <= res[8];
			res[10]<= res[9];
			res[11]<= res[10];
			res[12]<= res[11];
			res[13]<= res[12];
			res[14]<= res[13];
			res[15]<= res[14] ^ (res[15] ^ data); //generator polynomial
			count = count + 1; //increment to signify bit has been processed
		end
	end
endmodule
