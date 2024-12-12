`timescale 1ns/1ps

module time_counter(
    input CLK1,
    input RESET,
    input enable,

    input [3:0] min10,
    input [3:0] min01,
    input [3:0] sec10,
    input [3:0] sec01,

    output reg [3:0] next_min10,
    output reg [3:0] next_min01,
    output reg [3:0] next_sec10,
    output reg [3:0] next_sec01
);
    // 임시 변수로 계산
    reg [4:0] next_SEC01, next_SEC10, next_MIN01, next_MIN10;

    always @(posedge enable) begin

    end

    always @(posedge CLK1) begin
        if (RESET) begin
            next_min10 <= 4'd0;
            next_min01 <= 4'd0;
            next_sec10 <= 4'd0;
            next_sec01 <= 4'd0;
        end 
        else if (enable) begin
            // 초 단위 계산
            if(sec01 < 4'd9) begin
                next_SEC01 = sec01 + 1;
            end
            else begin
                next_SEC01 = 4'd0;

                if(sec10 < 4'd5) begin
                    next_SEC10 = sec10 + 1;
                end
                else begin
                    next_SEC10 = 4'd0;

                    if(min01 < 4'd9) begin
                        next_MIN01 = min01 + 1;
                    end
                    else begin
                        next_MIN01 = 4'd0;

                        if(min10 < 4'd5) begin
                            next_MIN10 = min10 + 1;
                        end
                        else begin
                            next_MIN10 = 4'd0;
                        end
                    end
                end
            end
        end
        // disable 일 때는 마지막 저장 값을 계속 현재 시간으로 load
        else begin
            next_MIN10 <= min10;
            next_MIN01 <= min01;
            next_SEC10 <= sec10;
            next_SEC01 <= sec01;
        end

        // 항상 출력 갱신 중 //
        next_min10 <= next_MIN10;
        next_min01 <= next_MIN01;
        next_sec10 <= next_SEC10;
        next_sec01 <= next_SEC01;
    end

endmodule
