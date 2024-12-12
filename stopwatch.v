`timescale 1ns / 1ps

module stopwatch(
    input clk100Hz,       // 100Hz 클럭 입력 (0.01초마다)
    input reset,          // 리셋 신호
    input start_stop,     // 시작/정지 버튼 입력 (button[0])
    output reg [6:0] sec, // 초 단위 (0~99)
    output reg [6:0] msec // 1/100초 단위 (0~99)
);

    reg running;          // 스톱워치 동작 상태 (1: 동작 중, 0: 정지)
    reg prev_button;      // 이전 버튼 상태 (엣지 검출용)

    initial begin
        running = 0;
        prev_button = 0;
        sec = 0;
        msec = 0;
    end

    // 시작/정지 버튼 처리
    always @(posedge clk100Hz or posedge reset) begin
        if (reset) begin // reset 시 초기화
            running <= 0;
            prev_button <= 0;
        end 
        else begin
            if (start_stop && !prev_button) begin // 버튼의 상승 에지 검출
                running <= ~running;  // running 상태 토글
            end 
            else begin
                running <= running;   // running 상태 유지
            end
            prev_button <= start_stop; // 현재 버튼 상태를 이전 상태로 저장
        end
    end

    // 시간 증가 로직
    always @(posedge clk100Hz or posedge reset) begin
        if (reset) begin // reset 시 초기화
            msec <= 0;
            sec <= 0;
        end 
        else begin
            if (running) begin
                // 1/100초 증가
                if (msec < 99) begin
                    msec <= msec + 1;
                    // sec는 유지됨
                end 
                else begin
                    msec <= 0;
                    if (sec < 99) begin
                        sec <= sec + 1;
                    end 
                    else begin
                        sec <= 0;
                    end
                end
            end 
            else begin
                msec <= msec;  // msec 상태 유지
                sec <= sec;    // sec 상태 유지
            end
        end
    end

endmodule
