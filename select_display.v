`timescale 1ns / 1ps

module select_display(
    input [14:0] SPDT,                 // select spdt (one-hot encoded)

    input [3:0] TIME_3,                // Time inputs
    input [3:0] TIME_2,
    input [3:0] TIME_1,
    input [3:0] TIME_0,

    input [3:0] STOPWATCH_3,           // Stopwatch inputs
    input [3:0] STOPWATCH_2,
    input [3:0] STOPWATCH_1,
    input [3:0] STOPWATCH_0,

    output reg [3:0] SEL_3,            // 3rd display
    output reg [3:0] SEL_2,            // 2nd display
    output reg [3:0] SEL_1,            // 1st display
    output reg [3:0] SEL_0             // 0th display
);

    always @(*) begin
        // 기본값 설정 
        SEL_3 = 4'b0000;
        SEL_2 = 4'b0000;
        SEL_1 = 4'b0000;
        SEL_0 = 4'b0000;

        // SPDT의 각 비트에 대해 선택 로직 구현
        // SPDT는 one-hot 인코딩이므로 하나의 비트만 1임
        case (1'b1)
            SPDT[0]: begin
                SEL_3 = TIME_3;
                SEL_2 = TIME_2;
                SEL_1 = TIME_1;
                SEL_0 = TIME_0;
            end

            SPDT[1]: begin
                SEL_3 = STOPWATCH_3;
                SEL_2 = STOPWATCH_2;
                SEL_1 = STOPWATCH_1;
                SEL_0 = STOPWATCH_0;
            end

            // 추가적인 SPDT 비트 처리
            // SPDT[2]: begin
            //     SEL_3 = OTHER_MODULE_3;
            //     SEL_2 = OTHER_MODULE_2;
            //     SEL_1 = OTHER_MODULE_1;
            //     SEL_0 = OTHER_MODULE_0;
            // end

            default: begin
                
            end
        endcase
    end

endmodule
