`timescale 1ns / 1ps

module segment_display(
    input MCLK,
    input [6:0] DISPLAY_3,  // 7-segment converted input
    input [6:0] DISPLAY_2,
    input [6:0] DISPLAY_1,
    input [6:0] DISPLAY_0,
    input clock_set,
    input alarm_set,
    input alarm_ringing,
    input [1:0] location,
    input [1:0] alarm_location,

    output reg [3:0] ANODE,     // Active-low
    output reg [6:0] SEG       // 7-segment output
    );

wire SCLK;
wire [1:0] iter;
reg [17:0] counter = 18'd0;
reg [24:0] blink_counter = 25'd0;  // Counter for 0.5-second blink signal
reg blink_state = 0;              // Blink state (on/off)

// Clock divider
always @(posedge MCLK) begin
    counter <= counter + 1;
end

assign SCLK = counter[15];       // Slower clock signal
assign iter = counter[17:16];    // Iteration index

// 0.5-second blink timer
always @(posedge MCLK) begin
    if (blink_counter == 25'd25_000_000 - 1) begin
        blink_counter <= 25'd0;
        blink_state <= ~blink_state; // Toggle blink state
    end else begin
        blink_counter <= blink_counter + 1;
    end
end

// Multiplexing logic with blinking
always @(posedge SCLK) begin
    case(iter)
        2'd0: begin
            ANODE <= 4'b1110;    // Enable segment 0
            if (alarm_ringing || (alarm_set && alarm_location == 2'd0) || (clock_set && location == 2'd0)) begin
                SEG <= blink_state ? DISPLAY_3 : 7'b1111111; // Blink logic
            end else begin
                SEG <= DISPLAY_3;
            end
        end
        2'd1: begin
            ANODE <= 4'b1101;    // Enable segment 1
            if (alarm_ringing || (alarm_set && alarm_location == 2'd1) || (clock_set && location == 2'd1)) begin
                SEG <= blink_state ? DISPLAY_2 : 7'b1111111; // Blink logic
            end else begin
                SEG <= DISPLAY_2;
            end
        end
        2'd2: begin
            ANODE <= 4'b1011;    // Enable segment 2
            if (alarm_ringing || (alarm_set && alarm_location == 2'd2) || (clock_set && location == 2'd2)) begin
                SEG <= blink_state ? DISPLAY_1 : 7'b1111111; // Blink logic
            end else begin
                SEG <= DISPLAY_1;
            end
        end
        2'd3: begin
            ANODE <= 4'b0111;    // Enable segment 3
            if (alarm_ringing || (alarm_set && alarm_location == 2'd3) || (clock_set && location == 2'd3)) begin
                SEG <= blink_state ? DISPLAY_0 : 7'b1111111; // Blink logic
            end else begin
                SEG <= DISPLAY_0;
            end
        end
        default: begin
            ANODE <= 4'b1111;    // Disable all segments
            SEG <= 7'b1111111;  // Blank display
        end
    endcase
end

endmodule

/* 우선순위 반영 : alarm_ringing>alarm_set>clock_set
module display_distribute(
    input MCLK,
    input [6:0] DISPLAY_3,  // 7-segment converted input
    input [6:0] DISPLAY_2,
    input [6:0] DISPLAY_1,
    input [6:0] DISPLAY_0,
    input clock_set,
    input alarm_set,
    input alarm_ringing,
    input [1:0] location,
    input [1:0] alarm_location,

    output reg [3:0] ANODE,     // Active-low
    output reg [6:0] SEG       // 7-segment output
    );

wire SCLK;
wire [1:0] iter;
reg [17:0] counter = 18'd0;
reg [24:0] blink_counter = 25'd0;  // Counter for 0.5-second blink signal
reg blink_state = 0;              // Blink state (on/off)

// Clock divider
always @(posedge MCLK) begin
    counter <= counter + 1;
end

assign SCLK = counter[15];       // Slower clock signal
assign iter = counter[17:16];    // Iteration index

// 0.5-second blink timer
always @(posedge MCLK) begin
    if (blink_counter == 25'd25_000_000 - 1) begin
        blink_counter <= 25'd0;
        blink_state <= ~blink_state; // Toggle blink state
    end else begin
        blink_counter <= blink_counter + 1;
    end
end

// Multiplexing logic with blinking
always @(posedge SCLK) begin
    case(iter)
        2'd0: begin
            ANODE <= 4'b1110;    // Enable segment 0
            if (alarm_ringing) begin
                SEG <= blink_state ? DISPLAY_3 : 7'b1111111; // Blink all segments
            end else if (alarm_set && alarm_location == 2'd0) begin
                SEG <= blink_state ? DISPLAY_3 : 7'b1111111; // Blink alarm location
            end else if (clock_set && location == 2'd0) begin
                SEG <= blink_state ? DISPLAY_3 : 7'b1111111; // Blink clock location
            end else begin
                SEG <= DISPLAY_3;
            end
        end
        2'd1: begin
            ANODE <= 4'b1101;    // Enable segment 1
            if (alarm_ringing) begin
                SEG <= blink_state ? DISPLAY_2 : 7'b1111111;
            end else if (alarm_set && alarm_location == 2'd1) begin
                SEG <= blink_state ? DISPLAY_2 : 7'b1111111;
            end else if (clock_set && location == 2'd1) begin
                SEG <= blink_state ? DISPLAY_2 : 7'b1111111;
            end else begin
                SEG <= DISPLAY_2;
            end
        end
        2'd2: begin
            ANODE <= 4'b1011;    // Enable segment 2
            if (alarm_ringing) begin
                SEG <= blink_state ? DISPLAY_1 : 7'b1111111;
            end else if (alarm_set && alarm_location == 2'd2) begin
                SEG <= blink_state ? DISPLAY_1 : 7'b1111111;
            end else if (clock_set && location == 2'd2) begin
                SEG <= blink_state ? DISPLAY_1 : 7'b1111111;
            end else begin
                SEG <= DISPLAY_1;
            end
        end
        2'd3: begin
            ANODE <= 4'b0111;    // Enable segment 3
            if (alarm_ringing) begin
                SEG <= blink_state ? DISPLAY_0 : 7'b1111111;
            end else if (alarm_set && alarm_location == 2'd3) begin
                SEG <= blink_state ? DISPLAY_0 : 7'b1111111;
            end else if (clock_set && location == 2'd3) begin
                SEG <= blink_state ? DISPLAY_0 : 7'b1111111;
            end else begin
                SEG <= DISPLAY_0;
            end
        end
        default: begin
            ANODE <= 4'b1111;    // Disable all segments
            SEG <= 7'b1111111;  // Blank display
        end
    endcase
end

endmodule
*/