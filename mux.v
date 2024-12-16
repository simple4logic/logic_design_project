//////////////////////////////////////////////////////////////////////////////////
// Description  : MUX
// Purpose      : pick one which will be displayed
//////////////////////////////////////////////////////////////////////////////////

module mux(
    input [14:0] SPDT,                   // select spdt (one-hot encoded)

    input [3:0] TIME_3,                  // Time inputs
    input [3:0] TIME_2,
    input [3:0] TIME_1,
    input [3:0] TIME_0,

    input [3:0] ALARM_3,                // ALARM inputs
    input [3:0] ALARM_2,
    input [3:0] ALARM_1,
    input [3:0] ALARM_0,

    input [3:0] STOPWATCH_3,            // Stopwatch inputs
    input [3:0] STOPWATCH_2,
    input [3:0] STOPWATCH_1,
    input [3:0] STOPWATCH_0,

    input MINIGAME_ENABLE,              // MINIGAME 진입
    input [3:0] MINIGAME_0,             //  MINIGAME 점수

    output reg [3:0] SEL_3,             // 3rd display
    output reg [3:0] SEL_2,             // 2nd display
    output reg [3:0] SEL_1,             // 1st display
    output reg [3:0] SEL_0              // 0th display
);

wire [2:0] modes;
assign modes = SPDT[14:12];

    always @(*) begin

        // minigame 출력 -> 우선순위
        if(MINIGAME_ENABLE) begin   // MINIGAME_ENABLE = 1-> 미니게임으로 들어감
            SEL_3 <= 4'b0000;
            SEL_2 <= 4'b0000;
            SEL_1 <= 4'b0000;
            SEL_0 <= MINIGAME_0;
        end

        else begin
            case (modes)
            3'b100: begin             // time set
                SEL_3 <= TIME_3;
                SEL_2 <= TIME_2;
                SEL_1 <= TIME_1;
                SEL_0 <= TIME_0;
            end

            3'b010: begin             // ALARM
                SEL_3 <= ALARM_3;
                SEL_2 <= ALARM_2;
                SEL_1 <= ALARM_1;
                SEL_0 <= ALARM_0;
            end

            3'b001: begin             // stopwatch
                SEL_3 <= STOPWATCH_3;
                SEL_2 <= STOPWATCH_2;
                SEL_1 <= STOPWATCH_1;
                SEL_0 <= STOPWATCH_0;
            end

            default: begin             // 아무것도 없다면 -> 현재 시각
                SEL_3 <= TIME_3;
                SEL_2 <= TIME_2;
                SEL_1 <= TIME_1;
                SEL_0 <= TIME_0;
            end
        endcase

        end

    end

endmodule
