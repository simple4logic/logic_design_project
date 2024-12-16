//////////////////////////////////////////////////////////////////////////////////
// Description : Stopwatch Module
// Purpose     : Implements a stopwatch with 1Hz and 100Hz clock inputs.
//////////////////////////////////////////////////////////////////////////////////

module stopwatch(
    input CLK,                 // 1Hz clock input (ticks every second)
    input CLK2,                // 100Hz clock input (ticks every 0.01 seconds)
    input RESET,               // Reset signal (active high)
    input START_STOP,          // Start/Stop button input (button[4], debounced, single-cycle pulse)
    input ENABLE,              // Stopwatch enable signal

    output reg [3:0] SEC_10,   // 10 seconds digit
    output reg [3:0] SEC_01,   // 1 second digit
    output reg [3:0] MSEC_10,  // 10/100 milliseconds digit
    output reg [3:0] MSEC_01   // 1/100 milliseconds digit
);

    // Internal register declarations
    reg [6:0] sec;               // Seconds counter (0~99)
    reg [6:0] msec;              // Milliseconds counter (0~99)
    reg running;                 // Stopwatch running state (1: running, 0: stopped)

    /////////////////////////////////////////////////////////////////
    // Start/Stop Button Handling and Stopwatch State Management
    /////////////////////////////////////////////////////////////////
    // Use the 1Hz clock to toggle the running state to prevent multiple toggles
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            running <= 0;       // Stop stopwatch on reset
        end
        
        else begin
            if (!ENABLE) begin
                running <= 0;   // Stop stopwatch if ENABLE is 0
            end
            else begin
                if (START_STOP) begin
                    running <= ~running; // Toggle running state on button pulse
                end
            end
        end
    end

    /////////////////////////////////////////////////////////////////
    // Time Increment Logic Block
    /////////////////////////////////////////////////////////////////
    // Use the 100Hz clock to increment the milliseconds and seconds counters
    always @(posedge CLK2 or posedge RESET) begin
        if (RESET || !ENABLE) begin
            // Reset or disable the stopwatch
            msec <= 0;                   // Reset milliseconds
            sec  <= 0;                   // Reset seconds

            // Update outputs immediately on reset
            sec  <= 4'd0;
            msec <= 4'd0;
        end
        else begin
            if (running) begin
                if (sec == 99 && msec == 99) begin
                    // Reached maximum time (99:99), do not increment further
                    // Optionally, you can set a flag or trigger an event here
                end
                else if (msec < 99) begin
                    msec <= msec + 1;
                end
                else begin
                    msec <= 0;
                    if (sec < 99) begin
                        sec <= sec + 1;
                    end
                    else begin
                        sec <= 99;       // Fix seconds at 99
                    end
                end
            end
            // If not running, maintain current time (no changes to sec and msec)
            
            // BCD Conversion for seconds and milliseconds

        end
        SEC_10  <= sec / 10;            // Tens place of seconds
        SEC_01  <= sec % 10;            // Ones place of seconds
        MSEC_10 <= msec / 10;           // Tens place of milliseconds
        MSEC_01 <= msec % 10;           // Ones place of milliseconds
    end

endmodule
