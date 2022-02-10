module io(
	input wire clk,
	input wire reset,

	// CPU interface
	input wire 	[1:0] addr,
	input wire	[7:0] data_tx,
	output wire [7:0] data_rx,
	input wire cs_n,
	input wire oe_n,
	input wire we_n,

	// External pins
	inout wire [7:0] porta
);

	wire read  = !oe_n & !cs_n;
	wire write = !we_n & !cs_n;

	wire sel_conf = (addr == 2'b00);
	wire sel_port = (addr == 2'b01);


	wire [7:0] d_rx;
	wire dir_o;

	reg [7:0] p1_conf;

	// Infer configuration register
	always @(posedge clk) begin
		if (!reset) 
			p1_conf <= 8'h00;
		else if (write && sel_conf)
			p1_conf <= data_tx;
	end

	assign dir_o   = (p1_conf[0] == 1'b1);
	assign data_rx = (p1_conf[0] == 1'b0) ? d_rx : 8'b0;

	// Tristate IO pin 
	SB_IO #( 
		.PIN_TYPE(6'b 1001_01), 
		.PULLUP(1'b0),
		.IO_STANDARD("SB_LVCMOS")
	 ) io_port_a [7:0] ( 
		.PACKAGE_PIN(porta[7:0]), 
		.OUTPUT_CLK(clk & write),
		.INPUT_CLK(clk & read),
		.CLOCK_ENABLE(sel_port),
		.OUTPUT_ENABLE(dir_o), 
		.D_OUT_0(data_tx), 
		.D_IN_0(d_rx) 
	 ); 

endmodule
