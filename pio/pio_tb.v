`timescale 10ns/1ns

module pio_tb();

	reg CLK;
	reg RESET = 0;
	reg [1:0] ADDR;
	reg [7:0] DIN;
	wire [7:0] DOUT;
	wire [7:0] PORTA;
	reg CS = 1, WE = 1, OE = 1;


	initial begin
		CLK = 1'b0;
		forever #2 CLK = ~CLK;
	end

	initial begin
		#10 RESET = 1;
		#5 DIN = 8'h00; ADDR = 2'b00;
		#10 CS = 1'b0; WE = 1'b0;
		#10 CS = 1'b1; WE = 1'b1;
		#10 DIN = 8'h00;
		#5 DIN = 8'hFF; ADDR = 2'b00;
		#10 CS = 1'b0; WE = 1'b0;
		#10 CS = 1'b1; WE = 1'b1;
		#5 DIN = 8'h00; ADDR = 2'b00;
		#10 CS = 1'b0; WE = 1'b0;
		#10 CS = 1'b1; WE = 1'b1;
		#5 DIN = 8'hFF; ADDR = 2'b00;
		#10 CS = 1'b0; WE = 1'b0;
		#10 CS = 1'b1; WE = 1'b1;
		#200
		$finish;
	end

	initial begin
		$dumpfile("pio.vcd");
		$dumpvars;
	end

	io io_inst(
		.clk(CLK),
		.reset(RESET),
		.cs_n(CS),
		.we_n(WE),
		.oe_n(OE),
		.addr(ADDR),
		.data_tx(DIN),
		.data_rx(DOUT),
		.porta(PORTA)
	);

endmodule
