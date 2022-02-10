`timescale 10ns/1ns

module top_tb();

reg CLK;
wire TXD;
wire RXD;

initial begin
	$dumpfile("test.vcd");
	$dumpvars(0, top_inst);
	CLK = 0;
end

always
	#1.04 CLK = ~CLK;

initial begin
	#800000 $finish;
end


top top_inst(
	.clk12(CLK),
	.TXD(TXD),
	.RXD(RXD)
);

endmodule

