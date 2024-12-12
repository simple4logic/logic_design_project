`timescale 1ns / 1ps

module MFC_top(
    input MCLK, // board clk
    input [14:0] SPDT,
    input [4:0] button // 0: inc, 1: dec, 2: left, 3: right, 4: center
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

// button 신호를 나눠서 사용 // 아직 사용안함
// assign inc      = button[0];
// assign dec      = button[1];
// assign left     = button[2];
// assign right    = button[3];
// assign center   = button[4];

// 현재 시간 저장
reg [3:0] min10;
reg [3:0] min01;
reg [3:0] sec10;
reg [3:0] sec01;

// 1초 클럭 생성 모듈
wire CLK1;
make_clk MAKE_CLK(
    .MCLK(MCLK),
    .RESET(RESET),
    .CLK1(CLK1), // 1s clock
    .CLK2(/*blank*/) // 0.01s clock
);

// button input을 filtering 해주는 모듈
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

// 시간 1초씩 증가 - 시계 모듈
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

// 시간 새로 설정
wire [3:0] update_min10;
wire [3:0] update_min01;
wire [3:0] update_sec10;
wire [3:0] update_sec01;
wire [1:0] location;

time_set TIME_SETTING(
    .CLK(MCLK),
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

// Feedback logic: Store outputs and pass them as inputs
always @(posedge MCLK or posedge RESET) begin
    if (RESET) begin
        min10 <= 4'd0;
        min01 <= 4'd0;
        sec10 <= 4'd0;
        sec01 <= 4'd0;
    end
    
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
end

// output OUTPUT(
//     .MIN(MIN),
//     .SEC(SEC),
//     .BLNK_INDEX(BLNK_INDEX),
//     .BLNK_ENABLE(BLNK_ENABLE),

//     .ANODE(ANODE),
//     .SEG(SEG)
// );

endmodule

