# https://github.com/jimtremblay/ghdl-example/blob/master/Makefile
# VHDL files
FILES = *.vhdl

# Test Bench files
TB_FILES = *_tb.vhdl
TB_FILE = ${TB}_tb
WORKDIR = work

# GHDL config
UNAME_S := $(shell uname -s)
# Linux machine
ifeq ($(UNAME_S), Linux)
	UNAME_N := $(shell uname -n)
	ifeq ($(UNAME_N), louthirion-ThinkPad-L460)
		GHDL = /snap/bin/ghdl
	else
		GHDL = /usr/bin/ghdl
	endif
	WAVEFORM_VIEWER = /usr/bin/gtkwave
endif
# Mac OS
ifeq ($(UNAME_S), Darwin)
	GHDL = /opt/homebrew/Caskroom/ghdl/3.0.0/bin/ghdl
endif

# VHDL 2008 standard lets us print the value of a signal in assertions (https://ghdl.github.io/ghdl/using/ImplementationOfVHDL.html#vhdl-standards)
GHDL_FLAGS = --std=08 --workdir=$(WORKDIR)

# Simulation options
STOP_TIME = 100ns
GHDL_SIM_OPT = --stop-time=$(STOP_TIME)
.PHONY: clean

all : clean make run view

make : 
# strip removes whitespace from TB argument
# ifeq checks if the argument is defined
ifeq ($(strip $(TB)),)
	@echo "TB not set. Use TB=<value> to set it."
	@echo "Example: make TB=adder"
	@exit 1
endif
# Create temporal work directory
	@mkdir -p $(WORKDIR)
# Analyze the files
	@$(GHDL) -a -v $(GHDL_FLAGS) $(FILES)
# @$(GHDL) -a -v $(GHDL_FLAGS) $(TB_FILE)*
# Elaborate (create executable)
	@$(GHDL) -e -v $(GHDL_FLAGS) $(TB_FILE) 

run :
# Run the simulation
	@$(GHDL) -r $(GHDL_FLAGS) --workdir=$(WORKDIR) $(TB_FILE) --vcd=$(TB_FILE).vcd $(GHDL_SIM_OPT)
# Move the .vcd file to the work directory
	@mv $(TB_FILE).vcd $(WORKDIR)/

view:
	@$(WAVEFORM_VIEWER) --dump=$(WORKDIR)/$(TB_FILE).vcd

clean :
# Remove the work directory
	@rm -rf $(WORKDIR)