//////////////////////////////////////////////////////////////////////////////////
// Description  : TOP
// Purpose      : Main module that connects all the modules together
//////////////////////////////////////////////////////////////////////////////////

module MFC_top(
    input MCLK, // board clk
    input [14:0] SPDT,
    input [4:0] button, // 0: inc, 1: dec, 2: left, 3: right, 4: center


    output [3:0] ANODE,     // Active-low
    output [6:0] SEG,       // 7-segment output
    output [15:0] LED       // 총 16개 : 왼쪽에서부터 4개 mode / 10개 minigame / 1개 alarm ringing / 1개 CLK 
);

// related to control
wire clock_set, alarm_set, stop_watch, alarm_on;
// wire inc, dec, left, right, center;
wire [9:0] miniGame;
wire RESET;

// Separate SPDT signals
assign clock_set    = SPDT[14];
assign alarm_set    = SPDT[13];
assign stop_watch   = SPDT[12];
assign alarm_on     = SPDT[11];
assign miniGame     = SPDT[10:1];
assign RESET        = SPDT[0];

// current time value
reg [3:0] min10;
reg [3:0] min01;
reg [3:0] sec10;
reg [3:0] sec01;

// *********************** CLK generation *********************** //
// generate 1s, 0.01s clock
wire CLK1;
wire CLK2;
make_clk MAKE_CLK(
    .MCLK(MCLK),
    .RESET(RESET),
    .CLK1(CLK1), // 1s clock
    .CLK2(CLK2) // 0.01s clock
);


// *********************** button filtering *********************** //
// debouncing  + edge detection
wire filtered_button[4:0];

genvar i;
generate
    for (i = 0; i < 5; i = i + 1) begin : switch_handlers
        switch_input_handler SWITCH_HANDLER (
            .CLK(MCLK),
            .RESET(RESET),
            .raw_button(button[i]),
            .filtered_button(filtered_button[i])
        );
    end
endgenerate

// *********************** time counter module *********************** //
wire [3:0] next_min10;
wire [3:0] next_min01;
wire [3:0] next_sec10;
wire [3:0] next_sec01;

time_counter TIME_COUNTER(
    .CLK1(CLK1),
    .RESET(RESET),
    .enable(~clock_set),

    // input
    .min10(min10),
    .min01(min01),
    .sec10(sec10),
    .sec01(sec01),

    // output
    .next_min10(next_min10),
    .next_min01(next_min01),
    .next_sec10(next_sec10),
    .next_sec01(next_sec01)
);

// *********************** time set module *********************** //
wire [3:0] update_min10;
wire [3:0] update_min01;
wire [3:0] update_sec10;
wire [3:0] update_sec01;
wire [1:0] location;

time_set TIME_SETTING(
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(clock_set),

    // button control
    .inc    (filtered_button[0]),
    .dec    (filtered_button[1]),
    .left   (filtered_button[2]),
    .right  (filtered_button[3]),

    // input time (start from here)
    .cur_min10(min10),
    .cur_min01(min01),
    .cur_sec10(sec10),
    .cur_sec01(sec01),

    // output time
    .update_min10(update_min10),
    .update_min01(update_min01),
    .update_sec10(update_sec10),
    .update_sec01(update_sec01),

    // location
    .location(location)
);


// *********************** stop watch module *********************** //
wire [3:0] stopwatchSEC_10;
wire [3:0] stopwatchSEC_01;
wire [3:0] stopwatchMSEC_10;
wire [3:0] stopwatchMSEC_01;

stopwatch STOPWATCH(
    .CLK(MCLK), // master clock
    .CLK2(CLK2), // 0.01s clock
    .RESET(RESET),
    .ENABLE(stop_watch),
    .START_STOP(filtered_button[4]),

    // output reg -> assign to display
    .SEC_10 (stopwatchSEC_10),
    .SEC_01 (stopwatchSEC_01),
    .MSEC_10(stopwatchMSEC_10),
    .MSEC_01(stopwatchMSEC_01)
);

// *********************** Alarm time set module *********************** //
reg [3:0] alarm_min10;
reg [3:0] alarm_min01;
reg [3:0] alarm_sec10;
reg [3:0] alarm_sec01;

wire [3:0] alarm_update_min10;
wire [3:0] alarm_update_min01;
wire [3:0] alarm_update_sec10;
wire [3:0] alarm_update_sec01;
wire [1:0] alarm_location;

time_set ALARM_SETTING(
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(alarm_set),

    // button control
    .inc    (filtered_button[0]),
    .dec    (filtered_button[1]),
    .left   (filtered_button[2]),
    .right  (filtered_button[3]),

    // input time (start from here)
    .cur_min10(alarm_min10),
    .cur_min01(alarm_min01),
    .cur_sec10(alarm_sec10),
    .cur_sec01(alarm_sec01),

    // output time
    .update_min10(alarm_update_min10),
    .update_min01(alarm_update_min01),
    .update_sec10(alarm_update_sec10),
    .update_sec01(alarm_update_sec01),

    // location
    .location(alarm_location)
);

// *********************** Alarm detecting module *********************** //
wire alarm_ringing;     // alarm enable signal (when alarm time == current time)
wire minigame_enable;   // enter minigame signal
wire minigame_done;     // check if game is done
wire ring_condition;
assign ring_condition = alarm_on & ~alarm_set;

alarm_ring ALARM_RING(
    // input
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(ring_condition),
    .button(filtered_button[4]), // center button -> to enter minigame
    .minigame_done(minigame_done),
    
    // input - data of time
    .min10(min10),
    .min01(min01),
    .sec10(sec10),
    .sec01(sec01),
    .alarm_min10(alarm_min10),
    .alarm_min01(alarm_min01),
    .alarm_sec10(alarm_sec10),
    .alarm_sec01(alarm_sec01),

    // output
    .alarm_ringing(alarm_ringing),    // give info : blink or not
    .minigame_enable(minigame_enable)
);

// *********************** minigame *********************** //
wire [3:0] minigame_score;
wire [9:0] minigame_LED;

minigame MINIGAME(
    // inputs
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(minigame_enable),

    // game control input
    .SPDT(SPDT[10:1]),
    .seed(sec01),

    //output
    .done(minigame_done),
    .score(minigame_score), // minigame score, 0~4
    .LED(minigame_LED)
);


// *********************** manage register (by top) *********************** //
// current time feedback logic
always @(posedge MCLK or posedge RESET) begin
    if (RESET) begin
        // clock reset
        min10 <= 4'd0;
        min01 <= 4'd0;
        sec10 <= 4'd0;
        sec01 <= 4'd0;
    end

    else begin
        // when in clock set mode
        if (clock_set) begin
            min10 <= update_min10;
            min01 <= update_min01;
            sec10 <= update_sec10;
            sec01 <= update_sec01;
        end
        // normal mode (counting clock)
        else begin
            min10 <= next_min10;
            min01 <= next_min01;
            sec10 <= next_sec10;
            sec01 <= next_sec01;
        end
    end
end

// alarm feedback logic
always @(posedge MCLK or posedge RESET) begin
    if (RESET) begin
        alarm_min10 <= 4'd0;
        alarm_min01 <= 4'd0;
        alarm_sec10 <= 4'd0;
        alarm_sec01 <= 4'd0;
    end
    
    else begin
        if (alarm_set) begin
            alarm_min10 <= alarm_update_min10;
            alarm_min01 <= alarm_update_min01;
            alarm_sec10 <= alarm_update_sec10;
            alarm_sec01 <= alarm_update_sec01;
        end
    end
end


// *********************** MUX *********************** //
wire [3:0] SEL_3;
wire [3:0] SEL_2;
wire [3:0] SEL_1;
wire [3:0] SEL_0;

mux MUX(
    // inputs
    .SPDT(SPDT),

    .TIME_3(min10),
    .TIME_2(min01),
    .TIME_1(sec10),
    .TIME_0(sec01),

    .ALARM_3(alarm_min10),
    .ALARM_2(alarm_min01),
    .ALARM_1(alarm_sec10),
    .ALARM_0(alarm_sec01),

    .STOPWATCH_3(stopwatchSEC_10),
    .STOPWATCH_2(stopwatchSEC_01),
    .STOPWATCH_1(stopwatchMSEC_10),
    .STOPWATCH_0(stopwatchMSEC_01),

    .MINIGAME_ENABLE(minigame_enable),
    .MINIGAME_0(minigame_score),
    
    // outputs
    .SEL_3(SEL_3),
    .SEL_2(SEL_2),
    .SEL_1(SEL_1),
    .SEL_0(SEL_0)
);

// *********************** BCDto7seg *********************** //
wire [6:0] display_3;
wire [6:0] display_2;
wire [6:0] display_1;
wire [6:0] display_0;


bcdto7segment BCDTO7SEGMENT(
    .BCD_3(SEL_3),
    .BCD_2(SEL_2),
    .BCD_1(SEL_1),
    .BCD_0(SEL_0),

    //output
    .DISPLAY_3(display_3),
    .DISPLAY_2(display_2),
    .DISPLAY_1(display_1),
    .DISPLAY_0(display_0)
);


// *********************** segment_display->blinkblink*********************** //

segment_display SEGMENT_DISPLAY(
    // inputs
    .MCLK(MCLK),
    .RESET(RESET),
    .DISPLAY_3(display_3),
    .DISPLAY_2(display_2),
    .DISPLAY_1(display_1),
    .DISPLAY_0(display_0),

    .clock_set(clock_set),
    .alarm_set(alarm_set),
    .alarm_ringing(alarm_ringing),
    .location(location),
    .alarm_location(alarm_location),

    //output
    .ANODE(ANODE),     // Active-low
    .SEG(SEG)          // 7-segment output
);

// *********************** LED *********************** //

LED_display LED_DISPLAY(
    // inputs
    .MCLK(MCLK),
    .CLK1(CLK1),
    .RESET(RESET),

    .MODE(SPDT[14:11]), // mode 4bit
    .minigame(minigame_LED),
    .alarm_ringing(alarm_ringing),

    // outputs
    .LED(LED)
);


endmodule

