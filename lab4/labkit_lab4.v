`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Updated 9/29/2017 V2.0
// Create Date: 10/1/2015 V1.0
// Design Name: 
// Module Name: labkit
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


module labkit(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output[7:0] JA, 
   output VGA_HS, 
   output VGA_VS, 
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
   
    parameter DISARMED = 0, ARMED = 1, CNTDWN = 2, PASSCNTDWN = 3, ALARM = 4, ALARMEND = 5, ON = 6;
// create 25mhz system clock
    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//////////////////////////////////////////////////////////////////////////////////
//
//  remove these lines and insert your lab here
    wire [3:0] countdown_time; //time displayed
    wire [2:0] state; //state of fsm
    wire second_clock; //clock that goes by second for timer
    wire expired; //states whether or not the clock time is not active (the counting down has finished)
    reg synchro_out; //synchronizer output
    wire timer_reset; //bool to assert that the timer has reset to new value
    wire timer_start; //bool to assert that the timer should count down
    wire siren_on; //bool to say whether the siren should be on
    wire led; //led indicator for different states
    wire [1:0] timer_type; //classifies the timing type/parameter (arming, siren, etc.)
    wire [1:0] timer_state; //output for the state of the timer
    wire [3:0] time_screen; //output for display
    wire power; //car is on!!!
    wire done; //wire for testing the countdown timer
    wire blink; //bool for blinking for status
    wire work; //
    
    assign LED[1] = power;
    assign LED[7] = SW[7];
    assign LED[15] = hidden;
    assign LED[14] = brake;
    assign LED[13] = passenger;
    assign LED[12] = driver;
    assign LED[11] = done;
    assign LED[10] = reprgm;
    assign LED[9] = second_clock;
    assign LED[8] = siren_on;
    assign data[29:28] = timer_state;
    assign data[18:16] = state;
    assign data[3:0] = time_screen; 
    
    //new debounced buttons
    wire reprgm, hidden, driver, passenger, brake;
    debounce debounce_reprgm(.reset(), .clock(clock_25mhz), .noisy(BTNC), .clean(reprgm));
    debounce debounce_hidden(.reset(), .clock(clock_25mhz), .noisy(BTNU), .clean(hidden));
    debounce debounce_driver(.reset(), .clock(clock_25mhz), .noisy(BTNL), .clean(driver));
    debounce debounce_passenger(.reset(), .clock(clock_25mhz), .noisy(BTNR), .clean(passenger));
    debounce debounce_brake(.reset(), .clock(clock_25mhz), .noisy(BTND), .clean(brake));    
    
    //tested!
    time_parameter timeparam(.clock(clock_25mhz), .reset(SW[15]), .reprgm(reprgm), .state(timer_type), .time_selector(SW[5:4]), .switch_time(SW[3:0]), .time_val(countdown_time));
    
    //tested!
    timer datimer(.clock(clock_25mhz), .reset(timer_reset), .start(timer_start), .second(second_clock), .timer_val(countdown_time), .time_screen(time_screen), .out_state(timer_state), .expired(expired), .done(done));

    //tested!
    antitheft fsm(.clock(clock_25mhz), .start(power), .driver(driver), .passenger(passenger), .reprogram(reprgm), .rkelly(SW[7]), .expired(expired), .siren(siren_on), .led(led), .timer_reset(timer_reset), .timer_start(timer_start), .siren_out(siren_on_res), .timer_type(timer_type), .new_state(state), .blink(blink));

    //tested!
    fuel_pump fuel(.clock(clock_25mhz), .brake(brake), .hidden(hidden), .rkelly(SW[7]), .power(power));
    
    //tested!
    siren dasiren(.clock(clock_25mhz), .start(siren_on), .power(JA[0])); 
    
    //tested!
    divider timebysecond(.start(reprgm), .clock_25mhz(clock_25mhz), .clock(second_clock));
    
    status_indicator status_ind(.clock_25mhz(clock_25mhz), .second(second_clock), .blink(blink), .led(led), .light(LED[0]));
//
//////////////////////////////////////////////////////////////////////////////////




 
//////////////////////////////////////////////////////////////////////////////////
// sample Verilog to generate color bars
    
    wire [9:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, at_display_area;
    vga vga1(.vga_clock(clock_25mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.at_display_area(at_display_area));
        
    assign VGA_R = 4'b1111;
    assign VGA_G = 4'b1111;
    assign VGA_B = 4'b1111;
    assign VGA_HS = ~hsync;
    assign VGA_VS = ~vsync;
endmodule

module time_parameter(
    input clock, //25mhz generic clock
    input reset, //input to say that the time parameter has changed
    input reprgm, //button was pressed, gonna get new time programed
    input [1:0] state, //current timer state from fsm
    input [1:0] time_selector, //switch for choosing which delay to reprogram SW[5:4]
    input [3:0] switch_time, //switch for outputing time SW[3:0]
    output [3:0] time_val //actual countdown time sent to timer module
    );
    
    parameter ARMING_P = 2'b00, CNTDWN_P = 2'b01, PASSCNTDWN_P = 2'b10, ALARM_P = 2'b11;
    parameter DISARMED = 0, ACTIVATE = 1, ARMING = 2, ARMED = 3, CNTDWN = 4, ALARM = 5, ALARMEND = 6;
    parameter T_ARM_DELAY = 4'b0110, T_DRIVER_DELAY = 4'b1000, T_PASSENGER_DELAY = 4'b1111, T_ALARM_ON = 4'b1010;
    
    //registers for stepping into new delay times
    reg [3:0] new_arm_delay, new_driver_delay, new_passenger_delay, new_alarm_on;
    reg [3:0] arm_delay, driver_delay, passenger_delay, alarm_on;
    
    reg [3:0] new_time; //output
    
    assign time_val = new_time;
    
    always @(*) begin
        if (reset) begin //new delay times are set to default on reset
            new_arm_delay <= T_ARM_DELAY;
            new_driver_delay <= T_DRIVER_DELAY;
            new_passenger_delay <= T_PASSENGER_DELAY;
            new_alarm_on <= T_ALARM_ON;
        end
        else if (reprgm) begin //reprogram button pressed, the set time parameter gets changed based on the switches
            case (time_selector) 
                ARMING_P : new_arm_delay <= switch_time;
                CNTDWN_P : new_driver_delay <= switch_time;
                PASSCNTDWN_P : new_passenger_delay <= switch_time;
                ALARM_P : new_alarm_on <= switch_time;
                default : new_arm_delay <= new_arm_delay;
            endcase
        end
        else begin
            case (state) //sets the new_time for timer module based on state
                ARMING_P : new_time <= arm_delay;
                CNTDWN_P : new_time <= driver_delay;
                PASSCNTDWN_P : new_time <= passenger_delay;
                ALARM_P : new_time <= alarm_on;
                default : new_time <= new_time;
            endcase
        end
    end
    
    always @(posedge clock) begin //sets stuff on next step
        arm_delay <= new_arm_delay;
        driver_delay <= new_driver_delay;
        passenger_delay <= new_passenger_delay;
        alarm_on <= new_alarm_on;       
    end
    
endmodule

module timer(
    input clock,
    input reset, //reset
    input start, //start the timer!!
    input second,//second counter
    input [3:0] timer_val, //actual countodwn time from time_parameter module
    output [3:0] time_screen, //what is displayed on board
    output [1:0] out_state, //behavior of timer
    output expired, //lets you know if there was a countdown but its done, so a state should change
    output done //tester variable
    );
    
    parameter IDLE = 2'b00, NEW_VAL = 2'b01, COUNTDOWN = 2'b10, DONE = 2'b11; //the states for the timer
    
    reg  [3:0] count, next_count;
    reg [1:0] state, next_state;
    reg doner;
    
    assign expired = (state == COUNTDOWN && count ==  0);
    assign time_screen = count;
    assign out_state = state;
    assign done = doner;
    
    always @(posedge expired) doner <= !doner;
    
    always @ * begin 
          if (reset) begin //reset to idle
              next_state = IDLE;
              next_count = 4'b0000;
          end
          else case (state) 
               IDLE:      //do nothing 
                    begin  
                        next_state =  start ? NEW_VAL : state; //do nothing or go to new_val is start was asserted
                        next_count = 0;
                    end
    
               NEW_VAL:  //start counter
                    begin
                        next_state  = COUNTDOWN;
                        next_count  = timer_val;                             
                    end
                     
               COUNTDOWN: //stays in countdown until countdown is done
                    begin
                        next_state =  expired ? DONE : state;
                        next_count =  expired ? 4'b0 : (second ? count - 1 : count);
                    end
      
               DONE:  //go back to idle 
                    begin 
                        next_state = IDLE;
                        next_count = 4'b0;
                    end
               default :
                    begin
                        next_state = IDLE;
                        next_count = 4'b0;
                    end
          endcase
    end
    
    //iterate through that young second clock
    always @(posedge clock) begin 
        count <= next_count;
        state <= next_state;
    end 
endmodule

module antitheft(
    input clock, //normal 25mhz clock
    input start, //reset or start again from button
    input driver, //driver door from button
    input passenger, //passenger door from button
    input reprogram, //let fsm know reprogram happened from button (treat like start button)
    input rkelly, //ignition from button
    input expired, //from timer module, let the fsm know that a counter has finished
    output siren, //bool for knowing if siren should be on
    output led, //bool for knowing if led should be on to display being armed, alarming, or on
    output timer_reset, //reset the timer for new countdown value
    output timer_start, //have counter start
    output siren_out, //for siren being on for interval (when the door gets closed again)
    output [1:0] timer_type, //parameter for type of countdown we need for timer_parameter
    output [2:0] new_state, //the new state if changed for timer_parameter
    output blink
    );
    //Parameters for all the different states and different countdown types
    parameter DISARMED = 0, ACTIVATE = 1, ARMING = 2, ARMED = 3, CNTDWN = 4, ALARM = 5, ALARMEND = 6;
    parameter ARMING_P = 2'b00, CNTDWN_P = 2'b01, PASSCNTDWN_P = 2'b10, ALARM_P = 2'b11;
    
    reg restart_timer; 
    reg [1:0] timer_state;
    reg [2:0] state, neo_state;    
    reg siren_on = 0;
    reg siren_on_res = 0;
    reg start_timer = 0;
    reg led_on = 0;
    reg blink_on = 0;
    
    reg [1:0] neo_timer_state;
    reg neo_siren, neo_led, neo_blink, neo_timer_reset, neo_timer_start;
    
    assign siren = neo_siren;
    assign led = neo_led;
    assign blink = neo_blink;
    assign timer_reset = neo_timer_reset;
    assign timer_start = neo_timer_start;
    assign siren_out = siren_on_res;
    assign timer_type = neo_timer_state;
    assign new_state = state;
    
    always @(posedge clock) begin
        state <= neo_state;
        neo_timer_state = timer_state;
        neo_siren <= siren_on;
        neo_led <= led_on;
        neo_blink <= blink_on;
        neo_timer_reset <= restart_timer;
        neo_timer_start <= start_timer;
    end
    
    always @(*) begin
        //reset to Armed state
        if (start) neo_state = DISARMED;
        else if (reprogram) begin
            neo_state = ARMED;
            restart_timer = 1;
        end
        else case (state)
            DISARMED: 
                begin
                    //go to new state if ignition is off and door is opened
                    if (!rkelly && (driver || passenger)) neo_state = ACTIVATE;
                    else neo_state = state;
                    
                    siren_on = 0;
                    start_timer = 0;
                    blink_on = 0;
                    led_on = 0;
                end
            ACTIVATE:
                begin
                    //go to next state if doors are closed
                    if (!driver && !passenger) neo_state = ARMING;
                    else neo_state = state;
                    
                    restart_timer = 0;
                    siren_on = 0;
                    start_timer = 0;
                    blink_on = 0;
                    led_on = 0;
                end
            ARMING:
                begin                    
                    //its arming, have a countdown with the T_ARMING_DELAY
                    timer_state = ARMING_P; 
                    if (driver || passenger) begin //resets the timer if a door is opened before
                        neo_state = ACTIVATE;
                        restart_timer = 1;
                    end
                    else if(expired) neo_state = ARMED; //gets armed if the countdown finishes
                    else neo_state = state;
                    
                    siren_on = 0;
                    start_timer = 1;
                    blink_on = 0;
                    led_on = 0;      
                end
            ARMED:
                begin
                    //goes to next state if door is opened
                    if (driver || passenger) neo_state = CNTDWN;
                    else neo_state = state;
                    
                    //code for the blinking led
                    
                    restart_timer = 1;
                    siren_on = 0;
                    siren_on_res = 0;
                    start_timer = 0;
                    blink_on = 1;
                    led_on = 0;
                end
            CNTDWN:
                begin
                    //alarm countdown, time based on which door was opened
                    timer_state = (passenger) ? CNTDWN_P : PASSCNTDWN_P; 
                    if (expired) neo_state = ALARM; //goes to next state if time runs out
                    else if (rkelly) neo_state = DISARMED; //if ignition gets turned on
                    else neo_state = state;
                    
                    siren_on = 0;
                    start_timer = 1;

                    blink_on = 1;
                    led_on = 0;
                end
            ALARM:
                begin
                    //goes to next state where alarm starts to go away if doors are closed 
                    if (!driver && !passenger) neo_state = ALARMEND;
                    else neo_state = state;
                    
                    siren_on = 1;
                    siren_on_res = 1;
                    start_timer = 0;
                    
                    blink_on = 0;
                    led_on = 1;                  
                end
            ALARMEND:
                begin
                    //new countdown
                    timer_state = ALARM_P;
                    if (expired) neo_state = ARMED; //goes back to armed once time runs out
                    else neo_state = state;
                      
                    siren_on = 1;
                    start_timer = 1;         
                    
                    blink_on = 0;
                    led_on = 1;      
                end
            default:
                neo_state = ARMED;
        endcase
    end
endmodule

module fuel_pump(
    input clock,
    input brake, //brake from button
    input hidden, //hidden switch from button
    input rkelly, //ignition from button
    output power); //outputs to board to show if car is on
    
    reg on;
    
    assign power = on;
    
    always @(posedge clock) begin
        if (!on) on <= brake && hidden && rkelly; //turns car on if all 3 criteria is met
        else on <= rkelly; //keeps car on with ignition is on
    end
endmodule

module siren(
    input clock,
    input start, //input to know if siren should be on
    output power); //siren behavior to board/speaker
    
    parameter STEP = 10;
    
	reg audio_reg;
    reg [14:0] count;
    reg [14:0] endpoint = 67500;
    reg state = 0; // 1: increasing endpoint, 0: decreasing endpoint
    assign power = (start & audio_reg);
    always @(posedge clock) begin
        // keep endpoint bopping back and forth
        if (endpoint >= 67500) begin
            state <= 0;
        end
        else if (endpoint <= 38572) begin
            state <= 1;
        end
        if (count == endpoint) begin
            endpoint <= state ? endpoint + STEP : endpoint - STEP;
            count <= 0;
            audio_reg <= !audio_reg;  // toggle waveform
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

module divider(
    input start,
    input clock_25mhz,
    output clock
);
    parameter hertz = 25'd25000000; //for the da young 25mhz
    
    reg [24:0] count;
    reg started;
    //reg reset = 0;
    assign clock = (count == hertz); //one second has passed when the 25mhz cycles are done
    
    //always @(*) neo_count = (count == hertz) ? 0 : count + 1;
    
    always @(posedge clock_25mhz) begin
        if (start) begin     
            started <= 1;
            count <= 0; //start/reset the counter
            //reset = 1;
        end
        else if (started) begin
            //if (!start) reset = 0;
            count <= (count == hertz) ? 0 : count + 1; //iterate
        end
    end
endmodule

module status_indicator(
    input clock_25mhz,
    input second,
    input blink,
    input led,
    output light
    );
    
    reg toggle;
    
    reg states;
    
    assign light = states;
    always @(posedge clock_25mhz) begin
        toggle <= toggle + second;
        
        if (led) states <= 1;
        else if (blink) states <= toggle;
        else states <= 0;      
    end

endmodule

module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;

    // VERY BAD VERILOG
    // VERY BAD VERILOG
    // VERY BAD VERILOG
    // But it's a quick and dirty way to create a 25Mhz clock
    // Please use the IP Clock Wizard under FPGA Features/Clocking
    //
    // For 1 Hz pulse, it's okay to use a counter to create the pulse as in
    // assign onehz = (counter == 100_000_000); 
    // be sure to have the right number of bits.

    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
    
endmodule

module vga(input vga_clock,
            output reg [9:0] hcount = 0,    // pixel number on current line
            output reg [9:0] vcount = 0,    // line number
            output reg vsync, hsync, 
            output at_display_area);

   // Comments applies to XVGA 1024x768, left in for reference
   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   reg hblank,vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount == 639);    // active H  1023
   assign hsyncon = (hcount == 655);     // active H + FP 1047
   assign hsyncoff = (hcount == 751);    // active H + fp + sync  1183
   assign hreset = (hcount == 799);      // active H + fp + sync + bp 1343

   // vertical: 806 lines total
   // display 768 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount == 479);    // active V   767
   assign vsyncon = hreset & (vcount ==490 );     // active V + fp   776
   assign vsyncoff = hreset & (vcount == 492);    // active V + fp + sync  783
   assign vreset = hreset & (vcount == 523);      // active V + fp + sync + bp 805

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vga_clock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

   end

   assign at_display_area = ((hcount >= 0) && (hcount < 640) && (vcount >= 0) && (vcount < 480));

endmodule

