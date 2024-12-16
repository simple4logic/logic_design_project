module minigame(
    input MCLK,             // Main clock (50 MHz)
    input RESET,            // Reset signal
    input enable,           // 게임 시작 시그널
    input [9:0] SPDT,       // 10개 스위치 입력
    input [3:0] seed,       // 시드로 쓸 현재 시간 sec01
    
    output reg done,          // 게임 종료 신호 (1이면 종료)
    output reg [3:0] score,   // 게임 점수 (0~3) - 7세그에서 0000~0003으로 표시 가정
    output reg [9:0] LED     // LED 상태 (1개만 켜짐)
);

    // 상태 정의
    localparam S_IDLE       = 3'd0;  // 대기 상태 (게임 비활성)
    localparam S_INIT       = 3'd1;  // 초기화 (LED 끄기, 점수 초기화)
    localparam S_SHOW_LED   = 3'd2;  // 랜덤 LED 선택 및 켜기
    localparam S_WAIT_GUESS = 3'd3;  // 사용자 입력 대기 (2초)
    localparam S_CHECK      = 3'd4;  // 정답 체크
    localparam S_DONE       = 3'd5;  // 게임 종료 상태

    reg [2:0] state, next_state;

    reg [7:0] random_number;  
    reg [27:0] timer;               // 2초 타이머 (50 MHz * 2초 = 100,000,000)
    localparam TWO_SEC = 28'd200_000_000;

    reg prev_enable;
    wire enable_edge = (enable && !prev_enable);

    // 정답 체크용 변수
    reg [9:0] user_input;    // 2초 동안의 사용자 입력 저장
    reg [9:0] save_rand_num;

    // 간단한 의사 난수 발생기 (LFSR 방식 간략화)
    // 매 라운드 LED 선택 시 random_number 갱신
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            random_number <= ((seed + 5) % 8) + 2;
            // save_rand_num <= 10'b0;
        end 
        else if (state == S_SHOW_LED) begin
            random_number <= {random_number[6:0], random_number[7] ^ random_number[5] ^ random_number[4] ^ random_number[3]} % 10;
        end
    end

    // 게임 시작 감지
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            prev_enable <= 1'b0;
        end else begin
            prev_enable <= enable;
        end
    end

    // FSM
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                // testLED <= 1'b0;
                // enable 신호 들어오는 상승 엣지 감지 시 게임 시작
                if (enable_edge) next_state = S_INIT;
            end
            S_INIT: begin
                // testLED <= 1'b1;
                // 초기화 후 다음 상태로
                next_state = S_SHOW_LED;
            end
            S_SHOW_LED: begin
                // LED 켠 뒤 WAIT_GUESS 상태로 이동
                next_state = S_WAIT_GUESS;
            end
            S_WAIT_GUESS: begin
                // 2초 경과 시 CHECK로 이동
                if (timer == TWO_SEC) next_state = S_CHECK;
            end
            S_CHECK: begin
                // 정답 확인 후 점수에 따라 분기
                if (score >= 4'd3) next_state = S_DONE;  // 3회 정답 -> 게임 종료
                else next_state = S_SHOW_LED;            // 아니면 다음 라운드
            end
            S_DONE: begin
                // 게임 종료 상태, 다시 enable 누르면 재시작 가능하도록 IDLE로
                next_state = S_IDLE;
            end
        endcase
    end

    // 메인 시퀀셜 로직
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            state <= S_IDLE;
            done <= 1'b0;
            score <= 4'd0;
            LED <= 10'b0;
            timer <= 28'd0;
            user_input <= 10'b0;
        end 
        
        else begin
            state <= next_state;

            case (state)
                S_IDLE: begin
                    done <= 1'b0;
                    LED <= 10'b0;
                    score <= 4'd0;
                    timer <= 28'd0;
                    user_input <= 10'b0;
                end

                S_INIT: begin
                    // 게임 초기화
                    score <= 4'd0;
                    LED <= 10'b0;         // LED 모두 끄기
                    // 7세그는 외부에서 score=0을 0000으로 표시한다고 가정
                    timer <= 28'd0;
                    user_input <= 10'b0;
                end

                S_SHOW_LED: begin
                    // 랜덤 LED 하나 켜기
                    LED <= (10'b1 << (random_number));
                    save_rand_num <= (10'b1 << (random_number));
                    timer <= 28'd0;
                    user_input <= 10'b0;
                end

                S_WAIT_GUESS: begin
                    // 2초 동안 사용자 입력 모니터링
                    if (timer < TWO_SEC) begin
                        timer <= timer + 1;
                        // 사용자 입력 갱신 (LED 켜진 동안 스위치 상태 확인)
                        user_input <= SPDT;
                    end
                end

                S_CHECK: begin
                    // user_input에 근거해 정답 체크
                    // 정답 조건: user_input 중 random_number 해당 비트만 1, 나머지 0
                    // 즉 user_input == (1 << random_number)
                    if (user_input == (save_rand_num)) begin
                        // 정답
                        score <= score + 1;
                    end 
                    else begin//if (user_input != 10'b0) begin
                        // 오답 (반응을 안했거나, 잘못된 스위치를 올림림)
                        score <= 4'd0;
                    end
                    // LED 끄기
                    LED <= 10'b0;
                    timer <= 27'd0;
                end

                S_DONE: begin
                    // 게임 종료
                    done <= 1'b1;
                    LED <= 10'b0;
                end
            endcase
        end
    end

endmodule
