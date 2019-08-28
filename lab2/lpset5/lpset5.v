module fsm (
input req, clk,
output ras, mux, cas
);

        reg [3:0] state = 4'b0000;
        parameter [3:0] state0 = 4'b1010;
        parameter [3:0] state1 = 4'b0010;
        parameter [3:0] state2 = 4'b0110;
        parameter [3:0] state3 = 4'b0100;
        parameter [3:0] state4 = 4'b0101;
        
        always @(posedge clk) begin
                case(state)
                  state0 : state <= req ? state1: state0;
                  state1 : state <= state2;
                  state2 : state <= state3;
                  state3 : state <= state4;
                  state4 : state <= state0;
                  default: state <= state0;
                endcase
        end
        
        assign ras = state[3];
        assign mux = state[2];
        assign cas = state[1];
        
endmodule

module testbench();
  reg clk;
  reg req;
  wire ras, mux, cas;
  fsm test(.req(req), .clk(clk), .ras(ras), .mux(mux), .cas(cas));

 
    always #50 clk = ~clk;
 
  //initial begin
  //  clk = 0;
  //  forever #5 clk = ~clk;
  //end
  
  
  initial begin
	clk = 0;
	req = 0;
    #100;
    req = 1;
    #200;
    req = 0;
  end    
endmodule