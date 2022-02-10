// Simple 8N1 serial receiver
// Each serial bit is sampled 16 times

module uart_rx #(
	parameter F_OSC = 12_000_000,
	parameter BAUD_RATE = 19200
)(
	input wire clk,
	input wire reset,

	// Control
	output wire [7:0] data,
	output wire rdy, 

	// Serial line
	input wire rxd	
);

	localparam RX_COUNT = F_OSC / (BAUD_RATE * 16);

	reg [$clog2(RX_COUNT)-1:0] clk_cnt;

	reg [3:0] bit_cnt;
	reg [3:0] tick_cnt;
	reg [9:0] shift_reg;
	reg [2:0] sync_reg;
	reg busy;

	wire rx_tick;
	wire sample;
	wire start;
	wire fall_edge;

	wire done = (rx_tick & (bit_cnt == 4'd10));


	// Synchronize rxd to system clock
	// and detect falling edge / start bit
	always @(posedge clk)
		sync_reg <= { sync_reg[1:0], rxd };

	assign fall_edge = ~sync_reg[1] & sync_reg[2];
	assign start = fall_edge & !busy;


	// Control signals
	always @(posedge clk) begin
		if (!reset)
			busy <= 1'b0;
		else if (start)
			busy <= 1'b1;
		else if (done)
			busy <= 1'b0;
	end


	// Shift register
	always @(posedge clk) begin
		if (!reset) begin
			shift_reg <= 10'b0;
		end
		else if ((tick_cnt == 1) && rx_tick) begin
			shift_reg <= { sync_reg[1], shift_reg[9:1] };
		end
	end


	// Baud rate generator
	// Generate sampling ticks at frequency 16x baud rate	
	always @(posedge clk) begin
		if (!reset)
			clk_cnt <= 0;
		else begin
			clk_cnt <= clk_cnt + 1'b1;

			if (clk_cnt == (RX_COUNT -1))
				clk_cnt <= 0;
		end
	end

	assign rx_tick = (clk_cnt == (RX_COUNT -1));
	assign sample = (rx_tick & (tick_cnt == 0));


	// Sampling tick counter	
	always @(posedge clk) begin
		if (!busy)
			tick_cnt <= 4'd8;
		else if (rx_tick)
			tick_cnt <= tick_cnt - 1'b1;
	end

	// Bit counter
	always @(posedge clk) begin
		if (!busy) 
			bit_cnt <= 0;
		else if (sample)
			bit_cnt <= bit_cnt + 1'b1;
	end


	assign data = shift_reg[8:1];
	assign rdy = done;

endmodule
