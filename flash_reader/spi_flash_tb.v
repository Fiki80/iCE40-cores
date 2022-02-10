`timescale 1ns / 100ps

module spi_flash_tb();

	reg clk = 1'b0;
	reg reset = 1'b0;

	reg tb_start = 1'b0;
	reg start;

	reg [23:0] addr = 24'hABAFAB;
	reg [13:0] byte_count = 16;
	

	wire spi_clk;
	wire spi_cs;
	wire spi_mosi;
	wire spi_miso;

	wire rdy;
	
	wire [7:0] data;
	wire data_rdy;


	initial begin
		$readmemh("flash.mem", fl_mem, 0, 15);
		$dumpfile("spi_flash.vcd");
		$dumpvars(0, spi_flash_tb);
	end

	initial begin
		#100 reset = 1'b1;
		#50 tb_start = 1'b1;
		#1 tb_start = 1'b0;
		#5000 $finish;
	end

	always
		#10 clk = ~clk; // 50 Mhz

	// Synchronize start signal to arrive after positive clock
	always @(posedge clk)
		if (!reset)
			start <= 1'b0;
		else
			start <= tb_start;


	// ===========================
	//	Fake SPI flash / 16 Bytes
	// ===========================

	reg [2:0] fl_cnt_bit;
	reg [4:0] fl_cnt_byte;
	reg [7:0] fl_shift_reg;
	reg [7:0] fl_mem [0:15];

	wire fl_last_bit = &fl_cnt_bit;


	always @(negedge spi_cs) begin
		fl_cnt_bit  <= 3'b0;
		fl_cnt_byte <= 5'b0;
	end

	// Counters	
	always @(negedge spi_clk) begin
		if (!spi_cs) begin
			fl_cnt_bit <= fl_cnt_bit + 1;
			if (fl_last_bit)
				fl_cnt_byte <= fl_cnt_byte + 1;
		end
	end

	// Shift register
	always @(negedge spi_clk) begin
		if (fl_cnt_byte < 3)
			fl_shift_reg <= 8'b0;
		else if (fl_last_bit)
			fl_shift_reg <= fl_mem[fl_cnt_byte-3];
		else
			fl_shift_reg <= { fl_shift_reg[6:0], 1'b0 };
	end

	assign spi_miso = (!spi_cs) ? fl_shift_reg[7] : 1'bz;

	
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
		.data_rdy(data_rdy)
	);

endmodule
