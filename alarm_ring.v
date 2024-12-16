//////////////////////////////////////////////////////////////////////////////////
// Description : Alarm Ring Module
// Purpose     : Detects alarm conditions and triggers the alarm ring
//////////////////////////////////////////////////////////////////////////////////

module alarm_ring(
    input MCLK,
    input RESET,
    input enable,
    input button,
    input minigame_done,

    input [3:0] min10, min01, sec10, sec01, // 현재 시간
    input [3:0] alarm_min10, alarm_min01, alarm_sec10, alarm_sec01, // 알람 시간

    output reg alarm_ringing, // 알람이 울리고 있는 상태
    output reg minigame_enable // 미니게임 활성화 신호
);

// 알람 조건 확인 및 상태 설정
always @(posedge MCLK or posedge RESET) begin
    if (RESET) begin
        alarm_ringing <= 0;
        minigame_enable <= 0;
    end 

    else begin
        // 알람 활성화 시
        if (enable) begin
            // 알람 조건 충족 시 alarm_ringing 활성화
            if (min10 == alarm_min10 && min01 == alarm_min01 &&
                sec10 == alarm_sec10 && sec01 == alarm_sec01) begin
                alarm_ringing <= 1;
            end

            // 버튼 입력 시 미니게임 시작, alarm_ringing 비활성화
            if (alarm_ringing && button) begin
                minigame_enable <= 1;
                alarm_ringing <= 0;
            end
        end

        // 미니게임이 끝나면 minigame_enable 리셋 (외부 논리에서 관리 가능)
        if (minigame_done) begin
            minigame_enable <= 0;
        end
    end
end

endmodule
