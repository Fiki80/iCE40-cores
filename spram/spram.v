// Convert 16K x 16 SPRAM block into 32K x 8
// Intended to be used with Z80 CPU, added oe_n signal

module spram8(
	input wire clk,
	input wire cs_n,
	input wire oe_n,
	input wire we_n,
	input wire [14:0] addr,
	input wire [7:0] data_in,
	output wire [7:0] data_out
);

	wire [15:0] dout;
	wire [15:0] din;
	wire [3:0] maskwren;

	reg nib_sel;

	wire read_sel = !cs_n & !oe_n & we_n;
	wire write_sel = !cs_n & oe_n & !we_n;
	
	// Multiplexers
	assign data_out = read_sel ? (nib_sel ? dout[7:0] : dout[15:8]) : 8'b0;
	assign maskwren = addr[14] ? 4'b0011 : 4'b1100;


	// Registered nibble select, make sure data_out appears 
	// on the next clock edge
	always @(posedge clk)
		nib_sel <= addr[14];


	SB_SPRAM256KA spram
	  (
		.ADDRESS(addr[13:0]),
		.DATAIN({data_in, data_in}),
		.MASKWREN(maskwren),
		.WREN(write_sel),
		.CHIPSELECT(~cs_n),
		.CLOCK(clk),
		.STANDBY(1'b0),
		.SLEEP(1'b0),
		.POWEROFF(1'b1),
		.DATAOUT(dout)
	  );

endmodule

