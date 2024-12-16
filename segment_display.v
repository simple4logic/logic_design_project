//////////////////////////////////////////////////////////////////////////////////
// Description : Segment Display
// Purpose     : Display 4-digit 7-segment display
//////////////////////////////////////////////////////////////////////////////////

module segment_display(
    input MCLK,
    input RESET,
    input [6:0] DISPLAY_3,  // 7-segment converted input for digit 3
    input [6:0] DISPLAY_2,  // 7-segment converted input for digit 2
    input [6:0] DISPLAY_1,  // 7-segment converted input for digit 1
    input [6:0] DISPLAY_0,  // 7-segment converted input for digit 0,

    input clock_set,        // Clock set mode
    input alarm_set,        // Alarm set mode
    input alarm_ringing,    // Alarm ringing mode
    input [1:0] location,
    input [1:0] alarm_location,

    output reg [3:0] ANODE, // Active-low anode control
    output reg [6:0] SEG    // 7-segment display output
    );

    wire SCLK;
    wire [1:0] iter;            // 4개 digit을 순차적으로 출력하기 위한 iter 
    reg [17:0] counter = 18'd0; // 18-bit counter
    reg [24:0] blink_counter = 25'd0;  // Counter for 0.5-second blink signal
    reg blink_state = 0;              // Blink state (on/off)

    // Clock Divider
    always @(posedge MCLK) begin
        counter <= counter + 1;
    end

    assign SCLK = counter[15];
    assign iter = counter[17:16];

    // blink를 위한 counter
    always @(posedge MCLK or posedge RESET) begin
        if(RESET) begin
            blink_counter <= 25'd0;
            blink_state <= 1'b0;
        end

        else begin
            if (blink_counter == 25'd25_000_000 - 1) begin
                blink_counter <= 25'd0;
                blink_state <= ~blink_state; // Toggle blink state
            end 
            else begin
                blink_counter <= blink_counter + 1;
            end
        end
    end

    always @(posedge SCLK) begin
        case(iter)
            2'd0: begin
                ANODE <= 4'b1110;
                if (alarm_ringing || (alarm_set && alarm_location == 2'd0) || (clock_set && location == 2'd0)) begin
                    SEG <= blink_state ? DISPLAY_0 : 7'b1111111; // Blink logic
                end 
                else begin
                    SEG <= DISPLAY_0;
                end
            end
            2'd1: begin
                ANODE <= 4'b1101;
                if (alarm_ringing || (alarm_set && alarm_location == 2'd1) || (clock_set && location == 2'd1)) begin
                    SEG <= blink_state ? DISPLAY_1 : 7'b1111111; // Blink logic
                end 
                else begin
                    SEG <= DISPLAY_1;
                end
            end
            2'd2: begin
                ANODE <= 4'b1011;
                if (alarm_ringing || (alarm_set && alarm_location == 2'd2) || (clock_set && location == 2'd2)) begin
                    SEG <= blink_state ? DISPLAY_2 : 7'b1111111; // Blink logic
                end 
                else begin
                    SEG <= DISPLAY_2;
                end
            end
            2'd3: begin
                ANODE <= 4'b0111;
                if (alarm_ringing || (alarm_set && alarm_location == 2'd3) || (clock_set && location == 2'd3)) begin
                    SEG <= blink_state ? DISPLAY_3 : 7'b1111111; // Blink logic
                end 
                else begin
                    SEG <= DISPLAY_3;
                end
            end
            
            // 위치 지정 X, 모든 digit을 끔
            default: begin
                ANODE <= 4'b1111;
                SEG <= 7'b1111111;
            end
        endcase
    end

endmodule
