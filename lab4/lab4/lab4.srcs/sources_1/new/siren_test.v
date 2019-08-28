`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2018 07:59:30 PM
// Design Name: 
// Module Name: siren_test
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


module siren_test();
    reg siren;
    reg clock;
    wire siren_out;
    
    siren test(.clock(clock), .start(siren_on), .power(siren_out));
    
    always #5 clock = ~clock;
    initial begin
        siren = 0;
        clock = 0;
        
        #1000
        
        siren = 1;
        
        #9999999
        
        $stop();
    end  
endmodule
