//////////////////////////////////////////////////////////////////////////////////
// Description : Clock time counter
//////////////////////////////////////////////////////////////////////////////////

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

    always @(posedge CLK1 or posedge RESET) begin
        if (RESET) begin
            // Reset: 모든 값을 초기화
            next_min10 <= 4'd0;
            next_min01 <= 4'd0;
            next_sec10 <= 4'd0;
            next_sec01 <= 4'd0;
        end
        else if (enable) begin
            // 초 단위 계산
            if(sec01 < 4'd9) begin
                next_sec01 = sec01 + 1;
                next_sec10 = sec10;
                next_min01 = min01;
                next_min10 = min10;
            end
            else begin
                next_sec01 = 4'd0;

                if(sec10 < 4'd5) begin
                    next_sec10 = sec10 + 1;
                    next_min01 = min01;
                    next_min10 = min10;
                end
                else begin
                    next_sec10 = 4'd0;

                    if(min01 < 4'd9) begin
                        next_min01 = min01 + 1;
                        next_min10 = min10;
                    end
                    else begin
                        next_min01 = 4'd0;

                        if(min10 < 4'd5) begin
                            next_min10 = min10 + 1;
                        end
                        else begin
                            next_min10 = 4'd0;
                        end
                    end
                end
            end
        end
        else begin
            // disable일 때는 마지막 저장 값을 계속 현재 시간으로 load
            next_min10 <= min10;
            next_min01 <= min01;
            next_sec10 <= sec10;
            next_sec01 <= sec01;
        end
    end

endmodule
