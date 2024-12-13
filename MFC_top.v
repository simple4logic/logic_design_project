`timescale 1ns / 1ps

module MFC_top(
    input MCLK, // board clk
    input [14:0] SPDT,
    input [4:0] button, // 0: inc, 1: dec, 2: left, 3: right, 4: center

    output [3:0] ANODE,     // Active-low
    output [6:0] SEG       // 7-segment output

    // output [27:0] display_total, // 7-segment display(7bit) * 4 = 28 bit
    // output [15:0] LED // 왼쪽부터 4개 / 10개 / 1개
);

// related to control
wire clock_set, alarm_set, stop_watch, alarm_on;
// wire inc, dec, left, right, center;
wire [9:0] miniGame;
wire RESET;

// SPDP 신호를 나눠서 사용
assign clock_set    = SPDT[14];
assign alarm_set    = SPDT[13];
assign stop_watch   = SPDT[12];
assign alarm_on     = SPDT[11];
assign miniGame     = SPDT[10:1];
assign RESET        = SPDT[0];

// 현재 시간 저장
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
// 설정한 알람 시간 저장용
reg [3:0] alarm_min10;
reg [3:0] alarm_min01;
reg [3:0] alarm_sec10;
reg [3:0] alarm_sec01;

wire [3:0] alarm_update_min10;
wire [3:0] alarm_update_min01;
wire [3:0] alarm_update_sec10;
wire [3:0] alarm_update_sec01;
wire [1:0] alarm_location;

alarm_set ALARM_SET(
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(alarm_set),

    // button control
    .inc    (filtered_button[0]),
    .dec    (filtered_button[1]),
    .left   (filtered_button[2]),
    .right  (filtered_button[3]),

    // input time (start from here)
    .alarm_min10(alarm_min10),
    .alarm_min01(alarm_min01),
    .alarm_sec10(alarm_sec10),
    .alarm_sec01(alarm_sec01),

    // output time
    .alarm_update_min10(alarm_update_min10),
    .alarm_update_min01(alarm_update_min01),
    .alarm_update_sec10(alarm_update_sec10),
    .alarm_update_sec01(alarm_update_sec01),

    // location
    .location(alarm_location)
);



// *********************** Alarm detecting module *********************** //
wire alarm_ringing; //알람 울림
wire minigame_enable; //미니게임 활성화
wire minigame_done; //미니게임 끝
wire ring_condition;

assign ring_condition = alarm_on & ~alarm_set;

alarm_ring ALARM_RING(
    // input
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(ring_condition), //스위치
    .button(filtered_button[4]), // 미니게임 넘어가는 버튼
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
    .alarm_ringing(alarm_ringing),    // blink 정보. 디스플레이에 전달
    .minigame_enable(minigame_enable) //먹스에 전달
);

// *********************** minigame *********************** //
wire [3:0] minigame_0;

minigame MINIGAME(
    .MCLK(MCLK),
    .RESET(RESET),
    .enable(minigame_enable),
    .button(filtered_button[4]),

    //output
    .done(minigame_done),
    .MINIGAME_0(minigame_0)
);



// *********************** manage register (by top) *********************** //
// Feedback logic: Store outputs and pass them as inputs
always @(posedge MCLK or posedge RESET) begin
    if (RESET) begin
        // clock reset
        min10 <= 4'd0;
        min01 <= 4'd0;
        sec10 <= 4'd0;
        sec01 <= 4'd0;

        // alarm reset
        alarm_min10 <= 4'd0;
        alarm_min01 <= 4'd0;
        alarm_sec10 <= 4'd0;
        alarm_sec01 <= 4'd0;
    end
    
    // who will access global clock?
    else if (clock_set) begin // when clock set mode
        min10 <= update_min10;
        min01 <= update_min01;
        sec10 <= update_sec10;
        sec01 <= update_sec01;
    end
    else begin // when normal counter mode
        min10 <= next_min10;
        min01 <= next_min01;
        sec10 <= next_sec10;
        sec01 <= next_sec01;
    end

    // allow access to global alarm or not
    if (alarm_set) begin
        alarm_min10 <= alarm_update_min10;
        alarm_min01 <= alarm_update_min01;
        alarm_sec10 <= alarm_update_sec10;
        alarm_sec01 <= alarm_update_sec01;
    end
end

// *********************** MUX *********************** //
wire [3:0] SEL_3;
wire [3:0] SEL_2;
wire [3:0] SEL_1;
wire [3:0] SEL_0;

mux MUX(
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
    .MINIGAME_0(minigame_0),

    
    //output
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
    .BCD_3(SEL_2),
    .BCD_3(SEL_1),
    .BCD_3(SEL_0),

    //output
    .DISPLAY_3(display_3),
    .DISPLAY_2(display_2),
    .DISPLAY_1(display_1),
    .DISPLAY_0(display_0)
);


// *********************** segment_display->blinkblink*********************** //

segment_display SEGMENT_DISPLAY(
    .MCLK(MCLK),
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



// LED output 모듈  해야함
// 알람일때 전체 점멸, 미니게임일때 미니게임 모듈의 출력

endmodule

