module uart_tx #(
	parameter F_OSC = 12_000_000,
	parameter BAUD_RATE = 19200
)(
	input wire clk,
	input wire reset,

	// Control 
	input wire start,
	input wire [7:0] data,
	output wire busy,

	// Serial line
	output wire txd
);

	localparam TX_COUNT = F_OSC / BAUD_RATE;

	reg [$clog2(TX_COUNT)-1:0] sample_cnt;
	wire sample_tx = (sample_cnt == 0);

	reg [9:0] shift_reg;


	// Shift register
	always @(posedge clk) begin
		if (!reset)
			shift_reg <= 10'b0;
		else if (start & !busy)
			shift_reg <= { 1'b1, data, 1'b0 };
		else if (sample_tx) 
			shift_reg <= { 1'b0, shift_reg[9:1] };
	end

	// Counter to generate samples at baud rate
	always @(posedge clk) begin
		if (!reset || sample_cnt == 0) begin
			sample_cnt <= TX_COUNT-1;
		end
		else if (busy) begin
			sample_cnt <= sample_cnt - 1'b1;
		end
	end
	
	// As long as there is 
	// stop bit (1'b1) in shift_reg, uart is busy
	assign busy = |shift_reg;
	assign txd = busy ? shift_reg[0] : 1'b1;

endmodule
