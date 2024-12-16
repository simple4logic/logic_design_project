//////////////////////////////////////////////////////////////////////////////////
// Description  : LED Display
// Purpose      : Display the LED (mode, alarm, minigame, clk)
//////////////////////////////////////////////////////////////////////////////////

module LED_display(
    input MCLK,
    input CLK1,
    input RESET,
    input [3:0] MODE,
    input [9:0] minigame,   // 10개
    input alarm_ringing,

    output reg [15:0] LED
    );

    // Internal counters
    reg [24:0] blink_counter;  // 25-bit counter for 0.5 sec at 50MHz
    reg blink_state;           // Blink state (on/off)

    // Blink logic: Toggle blink_state every 0.5 seconds when alarm_ringing is active
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            blink_counter <= 25'd0;
            blink_state <= 1'b0;
        end
        else if (alarm_ringing) begin
            if (blink_counter < 25_000_000 - 1) begin
                blink_counter <= blink_counter + 1;
            end
            else begin
                blink_counter <= 25'd0;
                blink_state <= ~blink_state; // Toggle blink state every 0.5 sec
            end
        end
        else begin
            blink_counter <= 25'd0;
            blink_state <= 1'b0; // Reset blink_state when not ringing
        end
    end

    // Assign LED outputs based on current state
    always @(*) begin
        if (alarm_ringing) begin
            // All LEDs blink at 0.5 sec intervals
            if (blink_state) begin
                LED = 16'b1111_1111_1111_1111; // All LEDs on
            end
            else begin
                LED = 16'b0000_0000_0000_0000; // All LEDs off
            end
        end

        else begin
            // LED[15:12] controlled by MODE
            LED[15:12] <= MODE;

            // LEDs[11:1] off
            LED[11:2] <= minigame;
            
            LED[1] <= 1'b0;

            // LED[0] toggles at 1Hz
            LED[0] <= CLK1;
        end
    end


endmodule