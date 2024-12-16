//////////////////////////////////////////////////////////////////////////////////
// Description : BCD to 7-segment decoder
// Purpose     : Convert BCD values to actual 7-segment display values
//////////////////////////////////////////////////////////////////////////////////

// decimal value => Actual display
module bcdto7segment(
    input [3:0] BCD_3,
    input [3:0] BCD_2,
    input [3:0] BCD_1,
    input [3:0] BCD_0,

    output reg [6:0] DISPLAY_3,
    output reg [6:0] DISPLAY_2,
    output reg [6:0] DISPLAY_1,
    output reg [6:0] DISPLAY_0

);
    always @ (*) begin
        case (BCD_3)
            4'd0: DISPLAY_3 = 7'b0000001;
            4'd1: DISPLAY_3 = 7'b1001111;
            4'd2: DISPLAY_3 = 7'b0010010;
            4'd3: DISPLAY_3 = 7'b0000110;
            4'd4: DISPLAY_3 = 7'b1001100;
            4'd5: DISPLAY_3 = 7'b0100100;
            4'd6: DISPLAY_3 = 7'b0100000;
            4'd7: DISPLAY_3 = 7'b0001111;
            4'd8: DISPLAY_3 = 7'b0000000; // 8 == TURN ON ALL
            4'd9: DISPLAY_3 = 7'b0000100;
            default: DISPLAY_3 = 7'b1111111; // NO display
        endcase

        case (BCD_2)
            4'd0: DISPLAY_2 = 7'b0000001;
            4'd1: DISPLAY_2 = 7'b1001111;
            4'd2: DISPLAY_2 = 7'b0010010;
            4'd3: DISPLAY_2 = 7'b0000110;
            4'd4: DISPLAY_2 = 7'b1001100;
            4'd5: DISPLAY_2 = 7'b0100100;
            4'd6: DISPLAY_2 = 7'b0100000;
            4'd7: DISPLAY_2 = 7'b0001111;
            4'd8: DISPLAY_2 = 7'b0000000; // 8 == TURN ON ALL
            4'd9: DISPLAY_2 = 7'b0000100;
            default: DISPLAY_2 = 7'b1111111; // NO display
        endcase

        case (BCD_1)
            4'd0: DISPLAY_1 = 7'b0000001;
            4'd1: DISPLAY_1 = 7'b1001111;
            4'd2: DISPLAY_1 = 7'b0010010;
            4'd3: DISPLAY_1 = 7'b0000110;
            4'd4: DISPLAY_1 = 7'b1001100;
            4'd5: DISPLAY_1 = 7'b0100100;
            4'd6: DISPLAY_1 = 7'b0100000;
            4'd7: DISPLAY_1 = 7'b0001111;
            4'd8: DISPLAY_1 = 7'b0000000; // 8 == TURN ON ALL
            4'd9: DISPLAY_1 = 7'b0000100;
            default: DISPLAY_1 = 7'b1111111; // NO display
        endcase

        case (BCD_0)
            4'd0: DISPLAY_0 = 7'b0000001;
            4'd1: DISPLAY_0 = 7'b1001111;
            4'd2: DISPLAY_0 = 7'b0010010;
            4'd3: DISPLAY_0 = 7'b0000110;
            4'd4: DISPLAY_0 = 7'b1001100;
            4'd5: DISPLAY_0 = 7'b0100100;
            4'd6: DISPLAY_0 = 7'b0100000;
            4'd7: DISPLAY_0 = 7'b0001111;
            4'd8: DISPLAY_0 = 7'b0000000; // 8 == TURN ON ALL
            4'd9: DISPLAY_0 = 7'b0000100;
            default: DISPLAY_0 = 7'b1111111; // NO display
        endcase
    end
endmodule
