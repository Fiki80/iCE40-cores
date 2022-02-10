module spi_flash(
	input wire clk,
	input wire reset,

	// SPI interface
	output wire spi_clk,
	input  wire spi_cs,
	output wire spi_mosi,
	input  wire spi_miso,

	// Control interface
	input  wire [23:0] addr,
	input  wire [13:0] byte_count,
	input  wire start,
	output reg  rdy,

	// Data interface
	output wire [7:0] data,
	output reg data_rdy
);

	localparam IDLE			= 2'b00;
	localparam SEND_CMD		= 2'b01;
	localparam READ_DATA	= 2'b10;

	// State registers
	reg [1:0]  cur_state, nxt_state;

	// Store byte count
	reg [13:0] byte_count_tmp;

	// Shift register
	reg [31:0] shift_reg;

	// Bit and byte counter registers
	reg [2:0]  cnt_bit;
	reg [14:0] cnt_byte;

	// Signal last bit and byte
	wire last_bit = (cnt_bit == 3'b111);
	wire last_cmd = (cnt_byte == 15'd3 & last_bit);
	wire last_data = (cnt_byte == (15'd3 + byte_count_tmp) & last_bit);

	// IO
	wire clk_en;
	wire spi_miso_buf;


	// FSM next state logic
	always @(*) begin
		// Default next state
		nxt_state = cur_state;

		case(cur_state)
			IDLE: begin
				if (start)
					nxt_state = SEND_CMD;
			end
			SEND_CMD: begin
				// Count 4 bytes
				if (last_cmd)
					nxt_state = READ_DATA;
			end
			READ_DATA: begin
				if (last_data)
					nxt_state = IDLE;
			end
		endcase
	end
	
	// FSM state memory
	always @(posedge clk) begin
		cur_state <= nxt_state;

		if (!reset)
			cur_state <= IDLE;
	end

	// Counters
	always @(posedge clk) begin
		if (start) begin
			cnt_bit <= 0;
			cnt_byte <= 0;
			byte_count_tmp <= byte_count;
		end
		else if (cur_state != IDLE) begin
			cnt_bit <= cnt_bit + 1;
			if (last_bit) 
				cnt_byte <= cnt_byte + 1;
		end
	end
	
	// Shift register
	always @(posedge clk) begin
		if (!reset)
			shift_reg <= 32'b0;
		else if (start)
			shift_reg <= { 8'h03, addr };
		else
			shift_reg <= { shift_reg[30:0], spi_miso_buf };
	end

	
	// IO
	assign spi_mosi = (cur_state == SEND_CMD) ? shift_reg[31] : 1'b0;
	assign spi_cs = (cur_state == IDLE);
	assign clk_en = (cur_state != IDLE);

	// Capture SPI data
	always @(posedge clk)
		data_rdy <= (cur_state == READ_DATA) & last_bit;

	assign data = shift_reg[7:0];

	// Ready signal
	always @(posedge clk) begin
		if (!reset)
			rdy <= 1'b0;
		else 
			rdy <= (cur_state == IDLE) & ~start;	
	end

	// SPI_CLK
	// Create inverted clock to internal clk
	SB_IO #(
		.PIN_TYPE(6'b0100_01),
		.PULLUP(1'b0),
		.NEG_TRIGGER(1'b0),
		.IO_STANDARD("SB_LVCMOS")
	) spi_clk1 (
		.PACKAGE_PIN(spi_clk),
		.CLOCK_ENABLE(1'b1),
		.OUTPUT_CLK(clk),
		.D_OUT_0(1'b0),
		.D_OUT_1(clk_en)
	);

	
	// SPI_MISO
	// Sample MISO line on negative edge of internal clock
	SB_IO #(
		.PIN_TYPE(6'b0000_00),
		.PULLUP(1'b0),
		.NEG_TRIGGER(1'b0),
		.IO_STANDARD("SB_LVCMOS")
	) spi_miso1 (
		.PACKAGE_PIN(spi_miso),
		.CLOCK_ENABLE(1'b1),
		.INPUT_CLK(clk),
		.D_IN_1(spi_miso_buf)
	);


endmodule
