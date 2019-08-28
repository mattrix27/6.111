module counter (clock, count);
   
   input clock;
   output [31:0] count;
   
   reg [31:0] count;
   
   always @(posedge clock)
     count = count+1;
      
endmodule