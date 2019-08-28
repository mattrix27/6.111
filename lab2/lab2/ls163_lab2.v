`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:53:19 09/18/2018 
// Design Name: 
// Module Name:    ls163_lab2 
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
module ls163_lab2(
    input clk,
    input ent,
    input enp,
    input load,
    input clear,
    input a,
    input b,
    input c,
    input d,
    output reg qa,
    output reg qb,
    output reg qc,
    output reg qd,
    output rco
    );

	  assign rco = qa & qb & qc & qd & ent;
	  always @(posedge clk) begin
		 if (clear == 0) {qd, qc, qb, qa} <= 4'b0000;
		 else if (load == 0) {qd, qc, qb, qa} <= {d, c, b, a};
		 else if (ent & enp) {qd, qc, qb, qa} <= {qd, qc, qb, qa} + 1;
	  end
  
endmodule
