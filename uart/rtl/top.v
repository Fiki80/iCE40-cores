module top(
	input wire clk12,
	input  wire RXD,
	output wire TXD
);

	parameter CLK_COUNT = 12_000_000;

	wire clk;
	assign clk = clk12;
	wire reset;
	wire busy;
	wire rdy;

	reg w_enable;

	reg [23:0] cntr;
	wire cnt = (cntr == CLK_COUNT);

	reg [7:0] char_rom [0:15];
	reg [3:0] char_pos;
	reg [7:0] tx_data;
	wire [7:0] rx_data;

	initial begin
		char_rom[0] = "H";
		char_rom[1] = "e";
		char_rom[2] = "l";
		char_rom[3] = "l";
		char_rom[4] = "o";
		char_rom[5] = " ";
		char_rom[6] = "w";
		char_rom[7] = "o";
		char_rom[8] = "r";
		char_rom[9] = "l";
		char_rom[10] = "d";
		char_rom[11] = "!";
		char_rom[12] = " ";
		char_rom[13] = " ";
		char_rom[14] = "\r";
		char_rom[15] = "\n";
	end


	reset reset_inst(
		.clk(clk), 
		.reset_n(reset)
	);

	uart_tx uart_tx_inst(
		.clk(clk),
		.reset(reset),
		.data(tx_data),
		.start(w_enable),
		.busy(busy),
		.txd(TXD)
	);

	wire LOOP = TXD;

	uart_rx uart_rx_inst(
		.clk(clk),
		.reset(reset),
		.data(rx_data),
		.rdy(rdy),
		.rxd(LOOP)
	);

	// Timer
	always @(posedge clk) begin
		if (!reset) begin
			cntr <= 24'b0;
		end	
		else begin
			cntr <= cntr + 1'b1;			
			if (cntr == CLK_COUNT)
				cntr <= 24'b0;
		end
	end


	always @(posedge clk) begin
//		tx_data <= rx_data;
		tx_data <= char_rom[char_pos];
	end


	always @(posedge clk) begin
		if (!reset)
			char_pos <= 0;
        else if ((!busy) && w_enable)
            char_pos <= char_pos + 1'b1;
	end


	always @(posedge clk) begin
		if (!reset)
			w_enable <= 1'b0;
		else if (cnt)
			w_enable <= 1'b1;
		else if ((w_enable)&&(!busy)&&(&char_pos))
			w_enable <= 1'b0;
	end


endmodule
