`timescale 1ns / 1ps

module make_clk(
    input MCLK,     // 50MHZ
    input RESET,
    output reg CLK1,    // 1Hz (1초 주기)
    output reg CLK2    // 100Hz (0.01초 주기)
    // output RESET_OUT
    );

    reg [26:0] clk1_counter;   // 1초짜리 clock용 카운터
    reg [19:0] clk2_counter;
    parameter CLK1_COUNT = 27'd100_000;  //27'd100_000_000; // 0.5초 (반주기)
    parameter CLK2_COUNT = 20'd1000;    //20'd1_000_000;    // 0.005초 (반주기)

    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            clk1_counter <= 27'd0;
            CLK1 <= 1'b0;
            clk2_counter <= 20'd0;
            CLK2 <= 1'b0;
        end 
        else begin
            // CLK2 생성
            if (clk2_counter < CLK2_COUNT - 1) begin
                clk2_counter <= clk2_counter + 1;
            end else begin
                clk2_counter <= 20'd0;
                CLK2 <= ~CLK2; // CLK2 반전
            end

            // CLK1 생성
            if (clk1_counter < CLK1_COUNT - 1) begin
                clk1_counter <= clk1_counter + 1;
            end else begin
                clk1_counter <= 27'd0;
                CLK1 <= ~CLK1; // CLK1 반전
            end
        end
    end

endmodule