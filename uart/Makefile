include proj.mk

YOSYS = yosys
YOSYS_SYNTH_ARGS = 
NEXTPNR = nextpnr
NEXTPNR_ARGS =
IVERILOG = iverilog
PROG = icesprog
PIN_DEF = ./common/$(PROJ).pcf

ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog
ICEBRAM = icebram
VERILATOR = verilator

.PHONY:	all sim synth clean prog lint

all: synth

BUILD_TMP := ./build_tmp
SIM = ./sim
SIM_TMP := ./sim_tmp

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

$(BUILD_TMP)/$(PROJ).ys: $(SRC)
	@echo "read_verilog $(SRC)" > $@
	@echo "synth_ice40 $(YOSYS_SYNTH_ARGS) -top $(PROJ_TOP) -json $(BUILD_TMP)/$(PROJ).json" >> $@

$(BUILD_TMP)/$(PROJ).json: $(SRC) $(BUILD_TMP)/$(PROJ).ys
	$(YOSYS) -s $(BUILD_TMP)/$(PROJ).ys -l $(BUILD_TMP)/$(PROJ).synth.rpt

$(BUILD_TMP)/$(PROJ).asc: $(BUILD_TMP)/$(PROJ).json $(PIN_DEF) 
	$(NEXTPNR) $(NEXTPNR_ARGS) \
		--$(DEVICE) --package $(PACKAGE) \
		--json $(BUILD_TMP)/$(PROJ).json \
		-l $(BUILD_TMP)/$(PROJ).pnr.rpt \
		--pcf $(PIN_DEF) --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

synth: $(BUILD_TMP) $(BUILD_TMP)/$(PROJ).bin

lint: $(SRC)
	$(VERILATOR) --lint-only $<

sim: $(SIM)/$(PROJ_TOP)_tb.v $(SRC)
	mkdir -p $(SIM_TMP)
	$(IVERILOG) -DNO_ICE40_DEFAULT_ASSIGNMENTS -l $$(yosys-config --datdir/ice40/cells_sim.v) -o $(SIM_TMP)/$(PROJ_TOP).out $^
	cd $(SIM_TMP) && vvp $(PROJ_TOP).out
	gtkwave $(SIM_TMP)/test.vcd
		

prog: $(BUILD_TMP)/$(PROJ).bin
	$(PROG) -w $<

clean:	
	@rm -Rf $(BUILD_TMP) $(SIM_TMP)
