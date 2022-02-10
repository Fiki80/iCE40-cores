/* Reset generator */
/* Reset signal stays low for 16 clock periods */

module reset(
	input  wire clk,
	output wire reset_n
);

	reg [3:0] reset_counter = 4'h0;

	always @(posedge clk) begin
		if (!reset_n)
			reset_counter <= reset_counter + 1'b1;
	end

	assign reset_n = &reset_counter;

endmodule
