//////////////////////////////////////////////////////////////////////////////////
// Description : Clock time set
//////////////////////////////////////////////////////////////////////////////////

module time_set(
    // module control
    input CLK,                  // 기본 클럭 (1s clk이 아닌, 그냥 clock)
    input RESET,                // 리셋 신호
    input enable,               // 설정 모드 진입

    // button control
    input inc,                  // 증가 버튼
    input dec,                  // 감소 버튼
    input left,                 // 왼쪽 버튼
    input right,                // 오른쪽 버튼

    // init time (current time)
    input [3:0] cur_min10,          // 10분 단위
    input [3:0] cur_min01,          // 01분 단위
    input [3:0] cur_sec10,          // 10초 단위
    input [3:0] cur_sec01,          // 01초 단위

    // output - actual time value
    output reg [3:0] update_min10,   // 10분 단위
    output reg [3:0] update_min01,   // 01분 단위
    output reg [3:0] update_sec10,   // 10초 단위
    output reg [3:0] update_sec01,    // 01초 단위
    // current location
    // [00, 01, 10, 11] from left to right
    output reg [1:0] location // 설정할 segment 위치
);
    // 임시 변수로 저장
    reg [4:0] _min10, _min01, _sec10, _sec01;

    //*********** time init before set ***********//
    always @(posedge enable) begin
        _min10 <= cur_min10;
        _min01 <= cur_min01;
        _sec10 <= cur_sec10;
        _sec01 <= cur_sec01;
    end

    //*********** location control ***********//
    always @(posedge CLK or posedge RESET) begin
        // reset
        if (RESET) begin
            location <= 2'b00;
        end

        // 설정 모드 진입 시
        else if (enable) begin // enable == 1
            if (left && location > 2'b00) begin
                location <= location - 1;
            end

            if (right && location < 2'b11) begin
                location <= location + 1;
            end
        end

        // enable 끌 때 초기화
        else begin // when enable == 0
            location <= 2'b00;
        end
    end

    //*********** value control ***********//
    always @(posedge CLK or posedge RESET) begin
        // reset
        if (RESET) begin
            update_min10 <= 0;
            update_min01 <= 0;
            update_sec10 <= 0;
            update_sec01 <= 0;
        end

        // 설정 모드 진입 시
        else if (enable) begin
            case (location)
                2'b00: begin // 10분 단위 // max = 5
                    if (inc) begin
                        if (_min10 == 5) begin
                            _min10 <= 0;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _min10 <= _min10 + 1;  // 증가
                        end
                    end
                    if (dec) begin
                        if (_min10 == 0) begin
                            _min10 <= 5;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _min10 <= _min10 - 1;  // 감소
                        end
                    end
                end

                2'b01: begin // 1분 단위
                    if (inc) begin
                        if (_min01 == 9) begin
                            _min01 <= 0;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _min01 <= _min01 + 1;  // 증가
                        end
                    end
                    if (dec) begin
                        if (_min01 == 0) begin
                            _min01 <= 4'd9;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _min01 <= _min01 - 1;  // 증가
                        end
                    end
                end

                2'b10: begin // 10초 단위 // max = 5
                    if (inc) begin
                        if (_sec10 == 5) begin
                            _sec10 <= 0;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _sec10 <= _sec10 + 1;  // 증가
                        end
                    end
                    if (dec) begin
                        if (_sec10 == 0) begin
                            _sec10 <= 5;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _sec10 <= _sec10 - 1;  // 증가
                        end
                    end
                end

                2'b11: begin // 1초 단위
                    if (inc) begin
                        if (_sec01 == 9) begin
                            _sec01 <= 0;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _sec01 <= _sec01 + 1;  // 증가
                        end
                    end
                    if (dec) begin
                        if (_sec01 == 0) begin
                            _sec01 <= 9;  // 최대값을 넘으면 0으로 초기화
                        end 
                        else begin
                            _sec01 <= _sec01 - 1;  // 감소
                        end
                    end
                end
            endcase

            // 결과 저장
            update_min10 <= _min10;
            update_min01 <= _min01;
            update_sec10 <= _sec10;
            update_sec01 <= _sec01;
        end
    end
endmodule
