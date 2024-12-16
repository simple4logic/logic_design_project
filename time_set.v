////////////////////////////////////////////////////////////////////////////////
// Description : Clock Time Set Module
// Purpose     : Allows setting of minutes and seconds using increment, decrement,
//               left, and right buttons.
////////////////////////////////////////////////////////////////////////////////

module time_set(
    input MCLK,                   // Main clock
    input RESET,                  // Reset signal
    input enable,                 // Enable signal for setting mode

    // Button control
    input inc,                    // Increment button
    input dec,                    // Decrement button
    input left,                   // Move left button
    input right,                  // Move right button

    // Current time inputs
    input [3:0] cur_min10,        // Tens place of minutes
    input [3:0] cur_min01,        // Ones place of minutes
    input [3:0] cur_sec10,        // Tens place of seconds
    input [3:0] cur_sec01,        // Ones place of seconds

    // Output - Updated time values
    output reg [3:0] update_min10,
    output reg [3:0] update_min01,
    output reg [3:0] update_sec10,
    output reg [3:0] update_sec01,
    output reg [1:0] location      // Current digit being configured
);

    // Temporary registers for internal manipulation
    reg [3:0] _min10, _min01, _sec10, _sec01;
    reg prev_enable;                // Previous state of enable for edge detection

    //*********** Initialize and Value Control ***********//
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            // Reset all internal registers
            _min10       <= 4'd0;
            _min01       <= 4'd0;
            _sec10       <= 4'd0;
            _sec01       <= 4'd0;
            prev_enable  <= 1'b0;
        end 
        else begin
            // Detect rising edge of enable signal
            if (~prev_enable & enable) begin
                // Load current time into temporary registers on enable rising edge
                _min10 <= cur_min10;
                _min01 <= cur_min01;
                _sec10 <= cur_sec10;
                _sec01 <= cur_sec01;
            end

            // Modify based on location and button inputs only when enabled
            if (enable) begin
                case (location)
                    2'b11: begin // 10-minute digit (0-5)
                        if (inc) begin
                            if (_min10 == 5) begin
                                _min10 <= 0;  // Wrap around to 0
                            end 
                            else begin
                                _min10 <= _min10 + 1;  // Increment
                            end
                        end
                        if (dec) begin
                            if (_min10 == 0) begin
                                _min10 <= 5;  // Wrap around to 5
                            end 
                            else begin
                                _min10 <= _min10 - 1;  // Decrement
                            end
                        end
                    end

                    2'b10: begin // 1-minute digit (0-9)
                        if (inc) begin
                            if (_min01 == 9) begin
                                _min01 <= 0;  // Wrap around to 0
                            end 
                            else begin
                                _min01 <= _min01 + 1;  // Increment
                            end
                        end
                        if (dec) begin
                            if (_min01 == 0) begin
                                _min01 <= 9;  // Wrap around to 9
                            end 
                            else begin
                                _min01 <= _min01 - 1;  // Decrement
                            end
                        end
                    end

                    2'b01: begin // 10-second digit (0-5)
                        if (inc) begin
                            if (_sec10 == 5) begin
                                _sec10 <= 0;  // Wrap around to 0
                            end 
                            else begin
                                _sec10 <= _sec10 + 1;  // Increment
                            end
                        end
                        if (dec) begin
                            if (_sec10 == 0) begin
                                _sec10 <= 5;  // Wrap around to 5
                            end 
                            else begin
                                _sec10 <= _sec10 - 1;  // Decrement
                            end
                        end
                    end

                    2'b00: begin // 1-second digit (0-9)
                        if (inc) begin
                            if (_sec01 == 9) begin
                                _sec01 <= 0;  // Wrap around to 0
                            end 
                            else begin
                                _sec01 <= _sec01 + 1;  // Increment
                            end
                        end
                        if (dec) begin
                            if (_sec01 == 0) begin
                                _sec01 <= 9;  // Wrap around to 9
                            end 
                            else begin
                                _sec01 <= _sec01 - 1;  // Decrement
                            end
                        end
                    end
                endcase
            end

            // Update previous enable state for next cycle
            prev_enable <= enable;
        end
    end

    //*********** Location Control ***********//
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            location <= 2'b00; // Default to 10-minute digit (most left)
        end
        else if (enable) begin
            if (left && location < 2'b11) begin
                location <= location + 1; // Move to left digit
            end

            if (right && location > 2'b00) begin
                location <= location - 1; // Move to right digit
            end
        end
        else begin
            location <= 2'b00; // Reset to default when not enabled
        end
    end

    //*********** Update Outputs ***********//
    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            // Reset all output registers
            update_min10 <= 4'd0;
            update_min01 <= 4'd0;
            update_sec10 <= 4'd0;
            update_sec01 <= 4'd0;
        end 
        else begin
            // Update output registers with temporary values
            update_min10 <= _min10;
            update_min01 <= _min01;
            update_sec10 <= _sec10;
            update_sec01 <= _sec01;
        end
    end

endmodule
