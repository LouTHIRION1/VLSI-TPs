GHDL = /opt/homebrew/Caskroom/ghdl/3.0.0/bin/ghdl

all : alu_tb
# ---------------- ALU ----------------
# Analyze (compile) the file
alu.o : alu.vhdl
	${GHDL} -a -v alu.vhdl

# Analyze both the test bench and object 
alu_tb.o : alu_tb.vhdl alu.o
	${GHDL} -a -v alu_tb.vhdl

# Elaborate (create executable)
alu_tb : alu.o alu_tb.o 
	${GHDL} -e -v alu_tb

run_alu : alu_tb
	${GHDL} -r alu_tb --vcd=alu.vcd

run : alu_tb
	./alu_tb --vcd=alu_tb.vcd

clean :
	rm *.o work-obj93.cf *_tb *.vcd

# ---------------- Adder ----------------
# Analyze (compile) the file
adder.o : adder.vhdl
	${GHDL} -a -v adder.vhdl

# Analyze both the test bench and object 
adder_tb.o : adder_tb.vhdl adder.o
	${GHDL} -a -v adder_tb.vhdl

# Elaborate (create executable)
adder_tb : adder.o adder_tb.o 
	${GHDL} -e -v  adder_tb

run_adder : adder_tb
	${GHDL} -r adder_tb --vcd=adder.vcd

# Elaborate and run executable
# adder_tb : adder.o adder_tb.o 
# ${GHDL} --elab-run adder_tb --vcd=adder.vcd

# ---------------- Shifter ----------------
shifter.o : shifter.vhdl
	${GHDL} -a -v shifter.vhdl