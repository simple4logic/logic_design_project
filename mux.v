`timescale 1ns / 1ps

module mux(
    input [14:0] SPDT,                 // select spdt (one-hot encoded)

    input [3:0] TIME_3,                // Time inputs
    input [3:0] TIME_2,
    input [3:0] TIME_1,
    input [3:0] TIME_0,

    input [3:0] ALARM_3,           // ALARM inputs
    input [3:0] ALARM_2,
    input [3:0] ALARM_1,
    input [3:0] ALARM_0,

    input [3:0] STOPWATCH_3,           // Stopwatch inputs
    input [3:0] STOPWATCH_2,
    input [3:0] STOPWATCH_1,
    input [3:0] STOPWATCH_0,

    input MINIGAME_ENABLE;              // MINIGame 들어가는거
    input [3:0] MINIGAME_0,            //  MINIGAME 숫자 0~3 정의, 1자리만 필요함

    output reg [3:0] SEL_3,            // 3rd display
    output reg [3:0] SEL_2,            // 2nd display
    output reg [3:0] SEL_1,            // 1st display
    output reg [3:0] SEL_0             // 0th display
);

    always @(*) begin
        // SPDT는 one-hot 인코딩이므로 하나의 비트만 1임

        if(MINIGAME_ENABLE) begin   // MINIGAME_ENABLE = 1-> 미니게임으로 들어감
            SEL_3 = 4'b0000;
            SEL_2 = 4'b0000;
            SEL_1 = 4'b0000;
            SEL_0 = MINIGAME_0;
        end

        else begin
            case (1'b1)
            SPDT[14]: begin             // SPDT[14] 들어옴
                SEL_3 = TIME_3;
                SEL_2 = TIME_2;
                SEL_1 = TIME_1;
                SEL_0 = TIME_0;
            end

            SPDT[13]: begin             // ALARM
                SEL_3 = ALARM_3;
                SEL_2 = ALARM_2;
                SEL_1 = ALARM_1;
                SEL_0 = ALARM_0;
            end

            SPDT[12]: begin             // stopwatch
                SEL_3 = STOPWATCH_3;
                SEL_2 = STOPWATCH_2;
                SEL_1 = STOPWATCH_1;
                SEL_0 = STOPWATCH_0;
            end

            default: begin             // 아무것도 안들어올시 현재시각으로 설정
                SEL_3 = TIME_3;
                SEL_2 = TIME_2;
                SEL_1 = TIME_1;
                SEL_0 = TIME_0;
            end
        endcase

        end

    end

endmodule
