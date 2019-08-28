`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:22:26 10/15/2018 
// Design Name: 
// Module Name:    lpset8 
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
`timescale 1ns / 1ps

module lpset8(
    input clock,
    input start,
    input data,
    output done,
    output [95:0] fec,
    output [7:0] fsm,
    output [15:0] cycle
    );
   
   //temp regs for shifting and checking
   reg [15:0] crc;
   reg [95:0] res;
   reg [8:0] count;
   reg [8:0] count_crc;
   reg three = 0;
   reg two =0;
   reg one =0;
   reg pbit0;
   reg pbit1;
   
   reg type;

   //assign outputs
   assign done = (count == 96);
   assign fec = res;
   assign fsm = type;
   assign cycle = crc;
   
   //cycling
   always @(posedge clock) begin
		type = (count >= 64);
		//reset to initial values
		if (start) begin
			res <= 96'h000000000000000000000000;
			crc <= 32'hFFFFFFFF;
			count <= 0;
			count_crc <= 0;
		end
		else begin
			//calculates CRC
			if (~type) begin
			  crc[0] <= crc[15] ^ data; //generator polynomial
			  crc[1] <= crc[0];
			  crc[2] <= crc[1] ^ (crc[15] ^ data); //generator polynomial
			  crc[3] <= crc[2];
			  crc[4] <= crc[3];
			  crc[5] <= crc[4];
			  crc[6] <= crc[5];
			  crc[7] <= crc[6];
			  crc[8] <= crc[7];
			  crc[9] <= crc[8];
			  crc[10]<= crc[9];
			  crc[11]<= crc[10];
			  crc[12]<= crc[11];
			  crc[13]<= crc[12];
			  crc[14]<= crc[13];
			  crc[15]<= crc[14] ^ (crc[15] ^ data); //generator polynomial
			end
			
      //does FEC stuff with proper data
			if (type) begin
			  three <= crc[15];
			  two <= three;
			  one <= two;
			  pbit1 = crc[15] ^ one ^ two;
			  pbit0 = crc[15] ^ three ^ two ^ one;
			  res[95:0] = {res[93:0], pbit1, pbit0};
			  crc = {crc[14:0], 1'b0};
			end

			else begin
			  three <= data;
			  two <= three;
			  one <= two;
			  pbit1 = data ^ one ^ two;
			  pbit0 = data ^ three ^ two ^ one;
			  res[95:0] = {res[93:0], pbit1, pbit0};
			end
			count = count + 2;
    end
   end
endmodule

module crc_tf;

   // Inputs
   reg clock;
   reg data_clk;
   reg start;
   reg data;

   // Outputs
   wire done;
   wire [95:0] fec;
	wire [7:0] fsm;
	wire [15:0] cycle;

   // Instantiate the Unit Under Test (UUT)
   lpset8 uut (
      .clock(clock), 
      .start(start), 
      .data(data), 
      .done(done), 
      .fec(fec),
		.fsm(fsm),
		.cycle(cycle)
   );

 // this is the input data
   reg [31:0] input_data = 32'h03_01_02_03;
   integer i;      // required for "for" loop

   initial begin   // system clock
      forever #5 clock = !clock;
      end
      
   initial begin   // data_clk, ensures setup time met               
      #2
      forever #5 data_clk = !data_clk;
      end
      
   initial begin
      // Initialize Inputs
      clock = 0;
      data_clk = 0;
      start = 0;
      data = 0;

      // Wait 100 ns for global reset to finish
      #100;
        
      // Add stimulus here
      start=1;
      #10 start = 0;
      #5;	// change if necessary for your design

      //forever #5 data_clk = !data_clk;
       for (i=0; i<48; i=i+1)
       begin
         data = input_data[31];
         // at each clock, left shift the data
         // note s     yntax for test bench "for" loop - no "always"
         // note the blocking assignment (immediate)
         @(posedge data_clk) input_data = {input_data[30:0],1'b0};     
       end
        
   $stop; // Pause simulation   
   end
      
endmodule
