//////////////////////////////////////////////////////////////////////////////////
// Description : Clock time set
//////////////////////////////////////////////////////////////////////////////////

module stopwatch(
    input CLK,                 // 1Hz 클럭 입력 (1초마다)
    input CLK2,                 // 100Hz 클럭 입력 (0.01초마다)
    input RESET,                // 리셋 신호 (active high)
    input START_STOP,           // 시작/정지 버튼 입력 (button[4])
    input ENABLE,               // SPDT 스톱워치 신호

    output reg [3:0] SEC_10,        // 10초 단위
    output reg [3:0] SEC_01,        // 1초 단위
    output reg [3:0] MSEC_10,       // 10/100초 단위
    output reg [3:0] MSEC_01        // 1/100초 단위
);

    // 내부 레지스터 선언
    reg [6:0] sec;               // 초 단위 (0~99)
    reg [6:0] msec;              // 1/100초 단위 (0~99)
    reg running;                 // 스톱워치 동작 상태 (1: 동작 중, 0: 정지)
    reg prev_button;             // 이전 버튼 상태 (엣지 검출용)

    
    /////////////////////////////////////////////////////////////////
    // 시작/정지 버튼 처리 블록
    /////////////////////////////////////////////////////////////////
    always @(posedge CLK or posedge RESET) begin
        if(RESET) begin
            running     <= 0;       // 스톱워치 정지
            prev_button <= 0;       // 이전 버튼 상태 초기화
            sec         <= 0;       // 분 정보 초기화   
            msec        <= 0;       // 초 정보 초기화
        end
        else begin
            if (!ENABLE) begin
                // ENABLE이 0인 경우
                running <= 0;               // 스톱워치 정지
                prev_button <= 0;           // 이전 버튼 상태 초기화
                sec <= 0;                   // 분 정보 초기화
                msec <= 0;                  // 초 정보 초기화
            end
            else begin
                if (START_STOP && !prev_button) begin
                    running <= ~running; // 스톱워치 동작 상태 토글
                end
                else begin
                    running <= running;  // 상태 유지
                end
                prev_button <= START_STOP; // 현재 버튼 상태를 이전 상태로 저장
            end
        end 
    end

    /////////////////////////////////////////////////////////////////
    // 시간 증가 로직 블록
    /////////////////////////////////////////////////////////////////
    always @(posedge CLK2 or posedge RESET) begin
        if (!ENABLE || RESET) begin
            // ENABLE이 0이거나 RESET이 1
            msec <= 0;                   // 1/100초 단위 초기화
            sec  <= 0;                   // 초 단위 초기화
        end
        else begin
            if (running) begin
                if (sec == 99 && msec == 99) begin //99:99 도달
                    msec <= msec;
                    sec  <= sec;
                end
                else if (msec < 99) begin
                    msec <= msec + 1;
                    sec  <= sec;          // sec 유지
                end
                else begin
                    msec <= 0;
                    if (sec < 99) begin
                        sec <= sec + 1;
                    end
                    else begin
                        sec <= 99;       // sec를 99로 고정하여 더 이상 증가하지 않음
                    end
                end
            end
            else begin
                msec <= msec;              // msec 상태 유지
                sec  <= sec;               // sec 상태 유지
            end
        end
    end


    assign SEC_10  = sec / 10;            // 10초 단위 계산
    assign SEC_01  = sec % 10;            // 1초 단위 계산
    assign MSEC_10 = msec / 10;           // 10/100초 단위 계산
    assign MSEC_01 = msec % 10;           // 1/100초 단위 계산

endmodule
