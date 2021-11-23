module reset(
	input wire clk,
	output wire reset_n
);

	reg [3:0] tick_count;

	always @(posedge clk) begin
		if(tick_count < 4'b1111)
			tick_count <= tick_count + 1;
	end

	assign reset_n = &tick_count;

endmodule
