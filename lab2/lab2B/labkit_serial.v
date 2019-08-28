///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module labkit (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
          ac97_bit_clock,
          
          vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
          vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
          vga_out_vsync,

          tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
          tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
          tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

          tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
          tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
          tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
          tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

          ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
          ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

          ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
          ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

          clock_feedback_out, clock_feedback_in,

          flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
          flash_reset_b, flash_sts, flash_byte_b,

          rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

          mouse_clock, mouse_data, keyboard_clock, keyboard_data,

          clock_27mhz, clock1, clock2,

          disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
          disp_reset_b, disp_data_in,

          button0, button1, button2, button3, button_enter, button_right,
          button_left, button_down, button_up,

          switch,

          led,
          
          user1, user2, user3, user4,
          
          daughtercard,

          systemace_data, systemace_address, systemace_ce_b,
          systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
          
          analyzer1_data, analyzer1_clock,
           analyzer2_data, analyzer2_clock,
           analyzer3_data, analyzer3_clock,
           analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
     vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
     tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
     tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
     tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
     tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
     button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
       analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // VGA Output
   assign vga_out_red = 10'h0;
   assign vga_out_green = 10'h0;
   assign vga_out_blue = 10'h0;
   assign vga_out_sync_b = 1'b1;
   assign vga_out_blank_b = 1'b1;
   assign vga_out_pixel_clock = 1'b0;
   assign vga_out_hsync = 1'b0;
   assign vga_out_vsync = 1'b0;

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
   assign ram0_we_b = 1'b1;
   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
//   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
//   assign disp_blank = 1'b1;
//   assign disp_clock = 1'b0;
//   assign disp_rs = 1'b0;
//   assign disp_ce_b = 1'b1;
//   assign disp_reset_b = 1'b0;
//   assign disp_data_out = 1'b0;
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
//   assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;

   assign analyzer3_clock = 1'b1;

   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;

   wire xmit_clk, start_send, enter_db;
   reg enter_old;

   // display "ASCII char is"
   wire [127:0] alpha =  {112'h4153434949206368617220697320,switch,8'h20};

   display_string ds1(.reset(1'b0), .clock_27mhz(clock_27mhz), .string_data(alpha),
	   .disp_blank(disp_blank), .disp_clock(disp_clock),.disp_rs(disp_rs), .disp_ce_b(disp_ce_b),
           .disp_reset_b(disp_reset_b), .disp_data_out(disp_data_out));

   debounce db_enter(.reset(1'b0), .clock(clock_27mhz), .noisy(~button_enter), .clean(enter_db));

   always @ (posedge clock_27mhz)
   enter_old <= enter_db;

   assign start_send = enter_db && !enter_old;

   rs232send sendx(.clk(clock_27mhz), .data(switch[7:0]), .start_send(start_send), 
	            .xmit_data(rs232_txd), .xmit_clk(xmit_clk));

   assign analyzer3_data = {switch,5'b0_0000,rs232_txd, xmit_clk, start_send};

   wire [7:0] data_out;
   wire data_valid;

   assign led = ~switch;
   endmodule

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- 16 characer ASCII string display 
//
//
// File:   display_string.v
// Date:   24-Sep-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Based on Nathan Ickes' hex display code
//
// 28-Nov-2006 CJT: fixed race condition between CE and RS
//
// This module drives the labkit hex displays and shows the value of 
// 8 ascii bytes as characters on the displays.
//
// Uses the Jae's ascii2dots module
//
// Inputs:
//
//   reset       - active high
//   clock_27mhz - the synchronous clock
//   string_data - 128 bits; each 8 bits gives an ASCII coded character
//   
// Outputs:
//
//    disp_*     - display lines used in the 6.111 labkit (rev 003 & 004)
//
///////////////////////////////////////////////////////////////////////////////

module display_string (
   input reset, clock_27mhz,    	// clock and reset (active high reset)
   input [16*8-1:0] string_data,	// 8 ascii bytes to display
   output disp_blank, disp_clock,   
   output reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b
	);
   
   ////////////////////////////////////////////////////////////////////////////
   //
   // Display Clock
   //
   // Generate a 500kHz clock for driving the displays.
   //
   ////////////////////////////////////////////////////////////////////////////
   
   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock;
   wire dreset;

   always @(posedge clock_27mhz)
     begin
	if (reset)
	  begin
	     count = 0;
	     clock = 0;
	  end
	else if (count == 26)
	  begin
	     clock = ~clock;
	     count = 5'h00;
	  end
	else
	  count = count+1;
     end
   
   always @(posedge clock_27mhz)
     if (reset)
       reset_count <= 100;
     else
       reset_count <= (reset_count==0) ? 0 : reset_count-1;

   assign dreset = (reset_count != 0);

   assign disp_clock = ~clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // Display State Machine
   //
   ////////////////////////////////////////////////////////////////////////////
      
   reg [7:0] state;		// FSM state
   reg [9:0] dot_index;		// index to current dot being clocked out
   reg [31:0] control;		// control register
   reg [3:0] char_index;	// index of current character
   wire [39:0] dots;		// dots for a single digit 
   reg [39:0] rdots;		// pipelined dots
   reg [7:0] ascii;		// ascii value of current character
   
   assign disp_blank = 1'b0; // low <= not blanked
   
   always @(posedge clock)
     if (dreset)
       begin
	  state <= 0;
	  dot_index <= 0;
	  control <= 32'h7F7F7F7F;
       end
     else
       casex (state)
	 8'h00:
	   begin
	      // Reset displays
	      disp_data_out <= 1'b0; 
	      disp_rs <= 1'b0; // dot register
	      disp_ce_b <= 1'b1;
	      disp_reset_b <= 1'b0;	     
	      dot_index <= 0;
	      state <= state+1;
	   end
	 
	 8'h01:
	   begin
	      // End reset
	      disp_reset_b <= 1'b1;
	      state <= state+1;
	   end
	 
	 8'h02:
	   begin
	      // Initialize dot register (set all dots to zero)
	      disp_ce_b <= 1'b0;
	      disp_data_out <= 1'b0; // dot_index[0];
	      if (dot_index == 639)
		state <= state+1;
	      else
		dot_index <= dot_index+1;
	   end
	 
	 8'h03:
	   begin
	      // Latch dot data
	      disp_ce_b <= 1'b1;
	      dot_index <= 31;		// re-purpose to init ctrl reg
	      state <= state+1;
	      disp_rs <= 1'b1; // Select the control register
	   end
	 
	 8'h04:
	   begin
	      // Setup the control register
	      disp_ce_b <= 1'b0;
	      disp_data_out <= control[31];
	      control <= {control[30:0], 1'b0};	// shift left
	      if (dot_index == 0)
		state <= state+1;
	      else
		dot_index <= dot_index-1;
	      char_index <= 15;		// set this up early for pipeline
	   end
	  
	 8'h05:
	   begin
	      // Latch the control register data / dot data
	      disp_ce_b <= 1'b1;
	      dot_index <= 39;		// init for single char
	      rdots <= dots;		// store dots of char 15
	      char_index <= 14;		// ready for next char
	      state <= state+1;
	      disp_rs <= 1'b0;	 		// Select the dot register
	   end
	 
	 8'h06:
	   begin
	      // Load the user's dot data into the dot reg, char by char
	      disp_ce_b <= 1'b0;
	      disp_data_out <= rdots[dot_index]; // dot data from msb
	      if (dot_index == 0)
	        if (char_index == 15)
	          state <= 5;			// all done, latch data
		else
		begin
		  char_index <= char_index - 1;	// goto next char
		  dot_index <= 39;
		  rdots <= dots;		// latch in next char dots
		end
	      else
		dot_index <= dot_index-1;	// else loop thru all dots 
	   end

       endcase

   // combinatorial logic to generate dots for current character
   // this mux, and the ascii table lookup, are slow, so note that
   // this is pipelined by one display clock stage in the always
   // loop above.

   always @(string_data or char_index)
     case (char_index)
       4'h0: ascii = string_data[7:0];
       4'h1: ascii = string_data[7+1*8:1*8];
       4'h2: ascii = string_data[7+2*8:2*8];
       4'h3: ascii = string_data[7+3*8:3*8];
       4'h4: ascii = string_data[7+4*8:4*8];
       4'h5: ascii = string_data[7+5*8:5*8];
       4'h6: ascii = string_data[7+6*8:6*8];
       4'h7: ascii = string_data[7+7*8:7*8];
       4'h8: ascii = string_data[7+8*8:8*8];
       4'h9: ascii = string_data[7+9*8:9*8];
       4'hA: ascii = string_data[7+10*8:10*8];
       4'hB: ascii = string_data[7+11*8:11*8];
       4'hC: ascii = string_data[7+12*8:12*8];
       4'hD: ascii = string_data[7+13*8:13*8];
       4'hE: ascii = string_data[7+14*8:14*8];
       4'hF: ascii = string_data[7+15*8:15*8];
     endcase

   ascii2dots a2d(ascii,dots);

endmodule

/////////////////////////////////////////////////////////////////////////////
// Display font dots generation from ASCII code

module ascii2dots(ascii_in,char_dots);

input [7:0] ascii_in;
output [39:0] char_dots;

  //////////////////////////////////////////////////////////////////////////
  // ROM: ASCII-->DOTS conversion
  //////////////////////////////////////////////////////////////////////////
	reg [39:0] char_dots;
	
	always @(ascii_in)
	 case(ascii_in)
		8'h20:	char_dots = 40'b00000000_00000000_00000000_00000000_00000000; //  32	' '
		8'h21:	char_dots = 40'b00000000_00000000_00101111_00000000_00000000; //  33	 !
		8'h22:	char_dots = 40'b00000000_00000111_00000000_00000111_00000000; //  34	"
		8'h23:	char_dots = 40'b00010100_00111110_00010100_00111110_00010100; //  35	 #
		8'h24:	char_dots = 40'b00000100_00101010_00111110_00101010_00010000; //  36	 $
		8'h25:	char_dots = 40'b00010011_00001000_00000100_00110010_00000000; //  37	 %
		8'h26:	char_dots = 40'b00010100_00101010_00010100_00100000_00000000; //  38	 &
		8'h27:	char_dots = 40'b00000000_00000000_00000111_00000000_00000000; //  39	'
		8'h28:	char_dots = 40'b00000000_00011110_00100001_00000000_00000000;//  40	 (
		8'h29:	char_dots = 40'b00000000_00100001_00011110_00000000_00000000; //  41	 )
		8'h2A:	char_dots = 40'b00000000_00101010_00011100_00101010_00000000; //  42	 *
		8'h2B:	char_dots = 40'b00001000_00001000_00111110_00001000_00001000; //  43	  +
		8'h2C:	char_dots = 40'b00000000_01000000_00110000_00010000_00000000; //  44	,
		8'h2D:	char_dots = 40'b00001000_00001000_00001000_00001000_00000000; //  45	 -
		8'h2E:	char_dots = 40'b00000000_00110000_00110000_00000000_00000000; //  46	 .
		8'h2F:	char_dots = 40'b00010000_00001000_00000100_00000010_00000000; //  47	 /
		8'h30:	char_dots = 40'b00000000_00011110_00100001_00011110_00000000; //  48	 0		--> 17
		8'h31:	char_dots = 40'b00000000_00100010_00111111_00100000_00000000; //  49	 1
		8'h32:	char_dots = 40'b00100010_00110001_00101001_00100110_00000000; //  50	 2
		8'h33:	char_dots = 40'b00010001_00100101_00100101_00011011_00000000; //  51	 3
		8'h34:	char_dots = 40'b00001100_00001010_00111111_00001000_00000000; //  52	 4
		8'h35:	char_dots = 40'b00010111_00100101_00100101_00011001_00000000; //  53	 5
		8'h36:	char_dots = 40'b00011110_00100101_00100101_00011000_00000000; //  54	 6
		8'h37:	char_dots = 40'b00000001_00110001_00001101_00000011_00000000; //  55	 7
		8'h38:	char_dots = 40'b00011010_00100101_00100101_00011010_00000000; //  56	 8
		8'h39:	char_dots = 40'b00000110_00101001_00101001_00011110_00000000; //  57	 9
		8'h3A:	char_dots = 40'b00000000_00110110_00110110_00000000_00000000; //  58	 :		--> 27
		8'h3B:	char_dots = 40'b01000000_00110110_00010110_00000000_00000000; //  59	 ;
		8'h3C:	char_dots = 40'b00000000_00001000_00010100_00100010_00000000; //  60	 <
		8'h3D:	char_dots = 40'b00010100_00010100_00010100_00010100_00000000; //  61	 =
		8'h3E:	char_dots = 40'b00000000_00100010_00010100_00001000_00000000; //  62	 >
		8'h3F:	char_dots = 40'b00000000_00000010_00101001_00000110_00000000; //  63	 ?
		8'h40:	char_dots = 40'b00011110_00100001_00101101_00001110_00000000; //  64	 @
		8'h41:	char_dots = 40'b00111110_00001001_00001001_00111110_00000000; //  65	 A		--> 34
		8'h42:	char_dots = 40'b00111111_00100101_00100101_00011010_00000000; //  66	 B
		8'h43:	char_dots = 40'b00011110_00100001_00100001_00010010_00000000; //  67	 C
		8'h44:	char_dots = 40'b00111111_00100001_00100001_00011110_00000000; //  68	 D
		8'h45:	char_dots = 40'b00111111_00100101_00100101_00100001_00000000; //  69	 E
		8'h46:	char_dots = 40'b00111111_00000101_00000101_00000001_00000000; //  70	 F
		8'h47:	char_dots = 40'b00011110_00100001_00101001_00111010_00000000; //  71	 G
		8'h48:	char_dots = 40'b00111111_00000100_00000100_00111111_00000000; //  72	 H
		8'h49:	char_dots = 40'b00000000_00100001_00111111_00100001_00000000; //  73	 I
		8'h4A:	char_dots = 40'b00010000_00100000_00100000_00011111_00000000; //  74	 J
		8'h4B:	char_dots = 40'b00111111_00001100_00010010_00100001_00000000; //  75	 K
		8'h4C:	char_dots = 40'b00111111_00100000_00100000_00100000_00000000; //  76	 L
		8'h4D:	char_dots = 40'b00111111_00000110_00000110_00111111_00000000; //  77	 M
		8'h4E:	char_dots = 40'b00111111_00000110_00011000_00111111_00000000; //  78	 N
		8'h4F:	char_dots = 40'b00011110_00100001_00100001_00011110_00000000; //  79	 O
		8'h50:	char_dots = 40'b00111111_00001001_00001001_00000110_00000000; //  80	 P
		8'h51:	char_dots = 40'b00011110_00110001_00100001_01011110_00000000; //  81	 Q
		8'h52:	char_dots = 40'b00111111_00001001_00011001_00100110_00000000; //  82	 R
		8'h53:	char_dots = 40'b00010010_00100101_00101001_00010010_00000000; //  83	 S
		8'h54:	char_dots = 40'b00000000_00000001_00111111_00000001_00000000; //  84	 T
		8'h55:	char_dots = 40'b00011111_00100000_00100000_00011111_00000000; //  85	 U
		8'h56:	char_dots = 40'b00001111_00110000_00110000_00001111_00000000; //  86	 V
		8'h57:	char_dots = 40'b00111111_00011000_00011000_00111111_00000000; //  87	 W
		8'h58:	char_dots = 40'b00110011_00001100_00001100_00110011_00000000; //  88	 X
		8'h59:	char_dots = 40'b00000000_00000111_00111000_00000111_00000000; //  89	 Y
		8'h5A:	char_dots = 40'b00110001_00101001_00100101_00100011_00000000; //  90	 Z		--> 59
		8'h5B:	char_dots = 40'b00000000_00111111_00100001_00100001_00000000; //  91	 [
		8'h5C:	char_dots = 40'b00000010_00000100_00001000_00010000_00000000; //  92	 \
		8'h5D:	char_dots = 40'b00000000_00100001_00100001_00111111_00000000; //  93	 ]
		8'h5E:	char_dots = 40'b00000000_00000010_00000001_00000010_00000000; //  94	 ^
		8'h5F:	char_dots = 40'b00100000_00100000_00100000_00100000_00000000; //  95	 _
		8'h60:	char_dots = 40'b00000000_00000001_00000010_00000000_00000000; //  96	 '
		8'h61:	char_dots = 40'b00011000_00100100_00010100_00111100_00000000; //  97	 a		--> 66
		8'h62:	char_dots = 40'b00111111_00100100_00100100_00011000_00000000; //  98	 b
		8'h63:	char_dots = 40'b00011000_00100100_00100100_00000000_00000000; //  99	 c
		8'h64:	char_dots = 40'b00011000_00100100_00100100_00111111_00000000; // 100	 d
		8'h65:	char_dots = 40'b00011000_00110100_00101100_00001000_00000000; // 101	 e
		8'h66:	char_dots = 40'b00001000_00111110_00001001_00000010_00000000; // 102	 f
		8'h67:	char_dots = 40'b00101000_01010100_01010100_01001100_00000000; // 103	 g
		8'h68:	char_dots = 40'b00111111_00000100_00000100_00111000_00000000; // 104	 h
		8'h69:	char_dots = 40'b00000000_00100100_00111101_00100000_00000000; // 105	 i
		8'h6A:	char_dots = 40'b00000000_00100000_01000000_00111101_00000000; // 106	 j
		8'h6B:	char_dots = 40'b00111111_00001000_00010100_00100000_00000000; // 107	 k
		8'h6C:	char_dots = 40'b00000000_00100001_00111111_00100000_00000000; // 108	 l
		8'h6D:	char_dots = 40'b00111100_00001000_00001100_00111000_00000000; // 109	 m
		8'h6E:	char_dots = 40'b00111100_00000100_00000100_00111000_00000000; // 110	 n
		8'h6F:	char_dots = 40'b00011000_00100100_00100100_00011000_00000000; // 111	 o
		8'h70:	char_dots = 40'b01111100_00100100_00100100_00011000_00000000; // 112	 p
		8'h71:	char_dots = 40'b00011000_00100100_00100100_01111100_00000000; // 113	 q
		8'h72:	char_dots = 40'b00111100_00000100_00000100_00001000_00000000; // 114	 r
		8'h73:	char_dots = 40'b00101000_00101100_00110100_00010100_00000000; // 115	 s
		8'h74:	char_dots = 40'b00000100_00011111_00100100_00100000_00000000; // 116	 t
		8'h75:	char_dots = 40'b00011100_00100000_00100000_00111100_00000000; // 117	 u
		8'h76:	char_dots = 40'b00000000_00011100_00100000_00011100_00000000; // 118	 v
		8'h77:	char_dots = 40'b00111100_00110000_00110000_00111100_00000000; // 119	 w
		8'h78:	char_dots = 40'b00100100_00011000_00011000_00100100_00000000; // 120	 x
		8'h79:	char_dots = 40'b00001100_01010000_00100000_00011100_00000000; // 121	 y
		8'h7A:	char_dots = 40'b00100100_00110100_00101100_00100100_00000000; // 122	 z		--> 91
		8'h7B:	char_dots = 40'b00000000_00000100_00011110_00100001_00000000; // 123	 {
		8'h7C:	char_dots = 40'b00000000_00000000_00111111_00000000_00000000; // 124	 |
		8'h7D:	char_dots = 40'b00000000_00100001_00011110_00000100_00000000; // 125	 }
		8'h7E:	char_dots = 40'b00000010_00000001_00000010_00000001_00000000; // 126	 ~		--> 95
		default:	char_dots = 40'b01000001_01000001_01000001_01000001_01000001;
    endcase

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Switch Debounce Module
//
///////////////////////////////////////////////////////////////////////////////

module debounce (
  input wire reset, clock, noisy,
  output reg clean
);
  reg [18:0] count;
  reg new;

  always @(posedge clock)
    if (reset) begin
      count <= 0;
      new <= noisy;
      clean <= noisy;
    end
    else if (noisy != new) begin
      // noisy input changed, restart the .01 sec clock
      new <= noisy;
      count <= 0;
    end
    else if (count == 270000)
      // noisy input stable for .01 secs, pass it along!
      clean <= new;
    else
      // waiting for .01 sec to pass
      count <= count+1;

endmodule

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:		 Gim P. Hom
//
// Create Date:    13:26:09 05/07/06
// Module Name:    rs232send
//
// Revision:		 08/11/2017
// Revision 0.01 - File Created		5/7/2006  GPH
// Additional Comments:	  This file will transmit ascii characters to a RS-232 
// interface. The baud rate for the example is preset to 115,200
//
// Character is sent when start_send goes high.
// 
// The calcuations assume a clock of 27 mhz.
//
// Baud Rate       DIVISOR  Exact   Actual Baud   % error
//  230,400         117    117.1875 230,769.23      0.16%
//  115,200         234    234.375  115,384.62      0.16%
//   57,600         468    468.75   57,692.31       0.16%
//   38,400         703    703.125  38,406.83       0.02%
//   19,200         1,406  1406.25  19,203.41       0.02%
//    9,600         2,812  2812.5   9,601.71        0.02%
//    4,800         5,625  5625     4,800.00        0.00%
//    2,400        11,250  11250    2,400.00        0.00%
//    1,200        22,500  22500    1,200.00        0.00%
////////////////////////////////////////////////////////////////////////////////
module rs232send(
    input clk,
    input [7:0] data,    // 8 bit ascii data
    input start_send,    // one clock pulse width, enter pressed, data available
    output xmit_data,    // serial data sent to RS232 output driver 
    output reg xmit_clk  // baud rate; sent to logic analyzer for debuggin
    );

    // this section sets up the clk;
    parameter DIVISOR =  234; // create 115,200 baud rate clock, not exact, but should work.
    parameter MARK = 1'b1;
    parameter STOP_BIT = 1'b1;
    parameter START_BIT =1'b0;
    
    reg [15:0] count;
    
    always @ (posedge clk)
    begin
       count <= xmit_clk ? 0 : count+1;
       xmit_clk <= count == DIVISOR-1;
    end
       
   ////////////////////////////////////////////////////////////////////////////
   //  insert your Verilog here
	reg [9:0] shift_reg;
	reg temp_data;
	always @ (posedge clk) begin
		if (start_send) begin
			shift_reg <= {STOP_BIT, data, START_BIT};
		end
		if (xmit_clk) begin
			temp_data <= data[0];
			shift_reg <= {STOP_BIT, shift_reg[9:1]};
		end
	end
	assign xmit_data = temp_data;
   //
   ////////////////////////////////////////////////////////////////////////////
           
endmodule

