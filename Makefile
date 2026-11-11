# EIE330 Lab 4 - Simple State Machine
# Run from this directory:
#   make check     syntax, lint and synthesis checks (Icarus, Verilator, Yosys)
#   make sim       all eight self-checking testbenches
#   make figures   regenerate the report figures from results/
#   make board     build and run the Simple VGA Simulator board model
#   make all       check + sim
IVERILOG ?= iverilog
VVP      ?= vvp
VERILATOR?= verilator
YOSYS    ?= yosys
PYTHON   ?= python3

RTL := RTL/pll.v RTL/key_debounce.v RTL/screen_fsm.v RTL/vga_ctrl.v \
       RTL/vga_pic.v RTL/vga_sm_top.v
TBS := tb_pll tb_vga_ctrl tb_key_debounce tb_screen_fsm tb_vga_pic \
       tb_vga_sm_top tb_vga_reset tb_no_debounce

.PHONY: all check sim figures board clean

all: check sim

results:
	mkdir -p results

check: | results
	$(IVERILOG) -g2012 -Wall -t null -s vga_sm_top $(RTL)
	$(VERILATOR) --lint-only -Wall --top-module vga_sm_top $(RTL)
	$(YOSYS) -p "read_verilog $(RTL); hierarchy -check -top vga_sm_top; \
	             proc; opt; check -assert; stat" > results/yosys_top.log
	$(YOSYS) -p "read_verilog $(RTL); hierarchy -check -top vga_sm_top; \
	             proc; opt; memory_map; opt; check -assert; stat -width" \
	             > results/yosys_mapped.log
	$(YOSYS) -p "read_verilog $(RTL); hierarchy -check -top vga_sm_top; \
	             proc; fsm_detect -ignore-self-reset; fsm_extract; fsm_opt; \
	             opt_clean; fsm_recode; opt; stat" > results/yosys_fsm.log
	@echo "check: iverilog / verilator / yosys clean"

sim: | results
	@for tb in $(TBS); do \
	  echo "== $$tb =="; \
	  $(IVERILOG) -g2012 -Wall -s $$tb -o results/$$tb.vvp Sim/$$tb.v -y RTL || exit 1; \
	  $(VVP) results/$$tb.vvp | tee results/$$tb.log; \
	done

figures:
	$(PYTHON) scripts/make_tikz.py ../../LaTeX/figures/bitmap_cells.tex
	$(PYTHON) scripts/make_figures.py --results results --out ../../LaTeX/figures
	@echo "figures: written to ../../LaTeX/figures"

board:
	cd Sim/board && ./run_simulation.sh ../../RTL

clean:
	rm -f results/*.vvp results/*.vcd results/*.log results/screen_*.hex
