`timescale 1us / 1ns

module tb_MFC_top;

    // Inputs
    reg MCLK; // Main clock (100 MHz)
    reg [14:0] SPDT; // Control signals
    reg [4:0] button; // Buttons for setting and interaction

    // Instantiate the MFC_top module
    MFC_top uut (
        .MCLK(MCLK),
        .SPDT(SPDT),
        .button(button)
    );

    integer i;

    // Clock generation
    always #5 MCLK = ~MCLK; // 10ns clock period (100 MHz)

    initial begin
        // Initialize Inputs
        MCLK = 0;
        SPDT = 15'b0; // All control signals off
        button = 5'b0;

        // ** Test Scenario 1: Reset and Initial Time **
        // Activate reset
        SPDT[0] = 1; // Reset signal on
        #1_000; // Wait for 1 second
        SPDT[0] = 0; // Reset signal off

        // Let the clock run naturally for a few seconds
        #1_000; // Wait for 5 seconds to observe normal operation
        #1_000;
        #1_000;
        #1_000;
        #1_000;
        
        // ** Test Scenario 2: alarm Set Mode - Adjust Time **
        SPDT[13] = 1; // Enter clock_set mode
        #1_000; // Wait for 1 second


        // ** Simulating Noisy Button Inputs to Test Debouncing **
        // Rapidly change button inputs to simulate noise
        for(i = 0; i < 50; i = i + 1) begin
            button[0] = ~button[0]; // Toggle button[0] rapidly
            // button[1] = ~button[1]; // Toggle button[1] rapidly
            #10; // Wait 10ns (simulate noisy signal)
        end

        // Increment time
        button[0] = 1; // Increment time
        #1_000; // Wait for 1 second
        button[0] = 0;

        // Rapidly change button inputs to simulate noise
        for(i = 0; i < 50; i = i + 1) begin
            button[3] = ~button[3]; // Toggle button[0] rapidly
            #10; // Wait 10ns (simulate noisy signal)
        end

        // Move to the next setting
        button[3] = 1; // Move right
        #1_000; // Wait for 1 second
        button[3] = 0;

        // Decrement time
        button[1] = 1; // Decrement time
        #1_000; // Wait for 1 second
        button[1] = 0;

        // Exit clock_set mode
        SPDT[13] = 0;
        #1_000; // Wait for 1 second

        ////////////////////////////////////////////////
        // Test Stop Watch Mode
        SPDT[12] = 1; // Activate stop_watch mode
        #1_000; // Wait for 1 second
        
        // Start stopwatch
        button[4] = 1; // Start stopwatch
        #1_000; // Wait for 1 second
        button[4] = 0; // Stop stopwatch

        // Wait for a few seconds
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second

        // Stop stopwatch
        button[4] = 1; // re-start stopwatch
        #1_000; // Wait for 1 second
        button[4] = 0; // stop stopwatch

        // ** Test for Time Counter **
        // Let time continue for a few seconds in normal mode
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        
        $stop;

        SPDT[12] = 1; // Activate stop_watch mode

        // Test button filtering and edge detection
        // Simulate noisy input for button[1] (decrement) rapidly
        for(i = 0; i < 50; i = i + 1) begin
            button[1] = ~button[1]; // Toggle button[1] rapidly
            #10; // Wait 10ns (simulate noisy signal)
        end

        // Verify time decrement (button[1])
        button[1] = 1; // Decrement time
        #1_000; // Wait for 1 second
        button[1] = 0;

        // ** Test for clock set mode with boundary conditions **
        SPDT[14] = 1; // Re-enter clock_set mode
        #1_000; // Wait for 1 second
        
        // Simulate boundary changes for time set
        button[0] = 1; // Increment time (min01 or sec01)
        #1_000; // Wait for 1 second
        button[0] = 0;

        // ** Test for alarm set mode **
        SPDT[13] = 1; // Enable alarm set
        #1_000; // Wait for 1 second

        // Stop test
        SPDT[13] = 0; // Deactivate alarm set
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second
        #1_000; // Wait for 1 second

        for(i = 0; i < 100; i = i + 1) begin
            #1_000; // Wait for 1 second
        end

        // End simulation
        $stop;
    end
endmodule
