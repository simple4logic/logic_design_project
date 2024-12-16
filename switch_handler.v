//////////////////////////////////////////////////////////////////////////////////
// Description : Handle switch input
// Purpose     : Debounce and detect rising edge of switch input
//////////////////////////////////////////////////////////////////////////////////

module switch_input_handler(
    input CLK,            // System clock
    input RESET,            // Reset signal
    input raw_button,     // Raw switch input (bouncy)
    output reg filtered_button // Processed switch signal (1 pulse per press)
);

    // Parameters for debouncing
    parameter DEBOUNCE_DELAY = 20_000; // Adjust as needed (e.g., 1ms for 20MHz clock)
    reg [15:0] debounce_counter;
    reg debounced_switch;

    // Registers for edge detection
    reg prev_debounced_switch;

    // Debouncing logic
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            debounce_counter <= 0;
            debounced_switch <= 0;
        end else begin
            // Check if the raw switch input is stable
            if (raw_button == debounced_switch) begin
                debounce_counter <= 0; // Reset counter if input is stable
            end 
            else begin
                // Increment counter if input is unstable
                if (debounce_counter < DEBOUNCE_DELAY) begin
                    debounce_counter <= debounce_counter + 1;
                end else begin
                    // Update the debounced switch after delay
                    debounced_switch <= raw_button;
                    debounce_counter <= 0; // Reset counter
                end
            end
        end
    end

    // Edge detection logic
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            prev_debounced_switch <= 0;
            filtered_button <= 0;
        end 
        else begin
            // Check for rising edge of the debounced switch
            filtered_button <= debounced_switch & ~prev_debounced_switch;
            prev_debounced_switch <= debounced_switch; // Update previous state
        end
    end

endmodule
