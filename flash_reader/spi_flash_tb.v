`timescale 1ns / 100ps

module spi_flash_tb();

	reg clk = 1'b0;
	reg reset = 1'b0;

	reg tb_start = 1'b0;
	reg start;

	reg [23:0] addr = 24'hABAFAB;
	reg [13:0] byte_count = 2;
	

	wire spi_clk;
	wire spi_cs;
	wire spi_mosi;
	reg spi_miso = 1'b0;

	wire rdy;
	
	wire [7:0] data;
	wire data_valid;


	initial begin
		$dumpfile("spi_flash.vcd");
		$dumpvars(0, spi_flash_tb);
	end

	initial begin
		#100 reset = 1'b1;
		#50 tb_start = 1'b1;
		#1 tb_start = 1'b0;
		#5000 $finish;
	end

	initial begin
		#811 spi_miso = 1'b1;
	end

	always
		#10 clk = ~clk; // 50 Mhz

	// Synchronize start signal to arrive after positive clock
	always @(posedge clk)
		if (!reset)
			start <= 1'b0;
		else
			start <= tb_start;


	spi_flash dut(
		.clk(clk),
		.reset(reset),
		.spi_clk(spi_clk),
		.spi_cs(spi_cs),
		.spi_mosi(spi_mosi),
		.spi_miso(spi_miso),
		.addr(addr),
		.byte_count(byte_count),
		.start(start),
		.rdy(rdy),
		.data(data),
		.data_valid(data_valid)
	);

endmodule
