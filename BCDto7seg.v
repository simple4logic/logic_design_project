//////////////////////////////////////////////////////////////////////////////////
// Description : BCD to 7-segment decoder
// input : 4-bit BCD
// output : actual 7-bit display data
//////////////////////////////////////////////////////////////////////////////////

// decimal value => Actual display
module BCDto7SegmentDecoder(
	input [3:0] bcd,
	output reg [6:0] display
	);
	always @ (*)
		begin
		case (bcd)
			4'd0: display = 7'b1111110;
			4'd1: display = 7'b0110000;
			4'd2: display = 7'b1101101;
			4'd3: display = 7'b1111001;
			4'd4: display = 7'b0110011;
			4'd5: display = 7'b1011011;
			4'd6: display = 7'b1011111;
			4'd7: display = 7'b1110000;
			4'd8: display = 7'b1111111; // 8 == TURN ON ALL
			4'd9: display = 7'b1111011;
			default: display = 7'b0000000; // NO display
		endcase
	end
endmodule