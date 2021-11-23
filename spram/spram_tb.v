`timescale 10ns/1ns

module spram_tb();

	reg CLK;
	reg [14:0] ADDRESS;
	reg [7:0] DIN;
	wire [7:0] DOUT;
	reg CS = 1, WE = 1, OE = 1;


	initial begin
		CLK = 1'b0;
		forever #2 CLK = ~CLK;
	end

	initial begin
		#30 CS = 1'b0;
		#30 WE = 1'b0;
		#5 ADDRESS = 15'h0000; DIN = 8'hAB;
		#5 ADDRESS = 15'h3FFF; DIN = 8'hAC;
		#5 ADDRESS = 15'h4000; DIN = 8'hAD;
		#5 ADDRESS = 15'h7FFF; DIN = 8'hAE;
		#5 WE = 1'b1; OE = 1'b0;
		#5 ADDRESS = 15'h0000;
		#5 ADDRESS = 15'h4000;
		#5 ADDRESS = 15'h7FFF;
		#9 ADDRESS = 15'h3FFF;
		#200
		$finish;
	end

	initial begin
		$dumpfile("spram.vcd");
		$dumpvars;
	end

	spram8 dut(
		.clk(CLK),
		.cs_n(CS),
		.we_n(WE),
		.oe_n(OE),
		.addr(ADDRESS),
		.data_in(DIN),
		.data_out(DOUT)
	);

endmodule
