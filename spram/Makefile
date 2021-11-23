NAME = spram
#GFLAGS = -S gtkwave.tcl


all: $(NAME).vcd
	#gtkwave $(GFLAGS) $<
	gtkwave $<

$(NAME).vcd: $(NAME).vvp
	vvp $<

$(NAME).vvp: $(NAME)_tb.v
	iverilog -Wall -o $@ $(NAME).v $(NAME)_tb.v -l $$(yosys-config --datdir/ice40/cells_sim.v)

.PHONY: clean
clean:
	@rm -f *.vcd *.vvp
