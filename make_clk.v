//////////////////////////////////////////////////////////////////////////////////
// Description  : make_clk
// Purpose      : Generate 1Hz and 100Hz clock signals
//////////////////////////////////////////////////////////////////////////////////

module make_clk(
    input MCLK,     // 50MHZ
    input RESET,
    output reg CLK1,    // 1Hz (1s 주기)
    output reg CLK2    // 100Hz (0.01s 주기)
    // output RESET_OUT
    );

    reg [26:0] clk1_counter;
    reg [19:0] clk2_counter;
    parameter CLK1_COUNT = 27'd50_000_000; // 0.5s
    parameter CLK2_COUNT = 20'd500_000;    // 0.005s 

    always @(posedge MCLK or posedge RESET) begin
        if (RESET) begin
            clk1_counter <= 27'd0;
            CLK1 <= 1'b0;
            clk2_counter <= 20'd0;
            CLK2 <= 1'b0;
        end 
        else begin
            if (clk2_counter < CLK2_COUNT - 1) begin
                clk2_counter <= clk2_counter + 1;
            end else begin
                clk2_counter <= 20'd0;
                CLK2 <= ~CLK2; // CLK2 반전
            end

            if (clk1_counter < CLK1_COUNT - 1) begin
                clk1_counter <= clk1_counter + 1;
            end else begin
                clk1_counter <= 27'd0;
                CLK1 <= ~CLK1; // CLK1 반전
            end
        end
    end

endmodule