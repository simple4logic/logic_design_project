//미니게임 모듈 (todo)
//일단 button 입력 들어오면 끝나는것으로 만들어둠!

module minigame(
    input MCLK,             // Main clock
    input RESET,            // Reset signal
    input enable,           // Enable signal for the mini-game
    input button,           // Button input (button[4])
    output reg done         // Done signal
    output reg [3:0] MINIGAME_0,        // 미니게임 숫자 세주는 변수
);

    // Sequential logic for the mini-game
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            done <= 0; // Reset the done signal
        end 
        else if (enable) begin
            if (button) begin
                done <= 1; // Set done when button is pressed
            end
            else begin
                done <= 0;
            end
        end 
        else begin
            done <= 0; // Clear done when minigame_enable is not active
        end
    end

    assign MINIGAME_0 = 4'b0000;

endmodule