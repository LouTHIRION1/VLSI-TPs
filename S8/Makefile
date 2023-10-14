all : exec decod ifetch mem.vst arm_core.vst arm_chip.vst
exec : alu.vst shifter.vst fifo_72b.vst exec_model.vst
decod : reg.vst fifo_32b.vst fifo_129b.vst decod_model.vst
ifetch : ifetch.vst ifetch_model.vst

#MBK_TARGET_LIB=/usr/share/alliance/cells/sxlib
MBK_TARGET_LIB=/soc/alliance/cells/sxlib

exec.vst : exec.vhdl alu.vst fifo_72b.vst shifter.vst
	vasy -I vhdl -V -o -a -p exec.vhdl exec

exec_model_o.vbe : exec.vst
	boom -V -O exec_model exec_model_o

exec_model.vst : exec_model_o.vbe
	boog exec_model_o exec_model

alu.vbe : alu.vhdl
	vasy -I vhdl -V -o -a -C 8 alu.vhdl alu

alu_o.vbe : alu.vbe
	boom -V -A -O alu alu_o

alu.vst : alu_o.vbe
	boog alu_o alu

shifter.vbe : shifter.vhdl
	vasy -I vhdl -V -o -a -C 8 shifter.vhdl shifter

shifter_o.vbe : shifter.vbe
	boom -V -A -O shifter shifter_o

shifter.vst : shifter_o.vbe
	boog shifter_o shifter

fifo_72b.vbe : fifo_72b.vhdl
	vasy -I vhdl -V -o -a fifo_72b.vhdl fifo_72b
	
fifo_72b_o.vbe : fifo_72b.vbe
	boom -V fifo_72b fifo_72b_o

fifo_72b.vst : fifo_72b_o.vbe
	boog fifo_72b_o fifo_72b

fifo_32b.vbe : fifo_32b.vhdl
	vasy -I vhdl -V -o -a fifo_32b.vhdl fifo_32b
	
fifo_32b_o.vbe : fifo_32b.vbe
	boom -V fifo_32b fifo_32b_o

fifo_32b.vst : fifo_32b_o.vbe
	boog fifo_32b_o fifo_32b

fifo_129b.vbe : fifo_129b.vhdl
	vasy -I vhdl -V -o -a fifo_129b.vhdl fifo_129b
	
fifo_129b_o.vbe : fifo_129b.vbe
	boom -V fifo_129b fifo_129b_o

fifo_129b.vst : fifo_129b_o.vbe
	boog fifo_129b_o fifo_129b

reg.vbe : reg.vhdl
	vasy -I vhdl -V -o -a -C 8 reg.vhdl reg

reg_o.vbe : reg.vbe
	boom -V -O reg reg_o

reg.vst : reg_o.vbe
	boog reg_o reg

decod_model_o.vbe : decod.vst decod_model.vbe 
	boom -V -A -O decod_model decod_model_o

decod_model.vst : decod_model_o.vbe
	boog decod_model_o decod_model

exec.vhd : exec.vst
	vasy -I vst -s -o -S exec exec

decod.vst : decod.vhdl reg.vst fifo_32b.vst fifo_129b.vst
	vasy -I vhdl -V -o -a -p decod.vhdl decod

ifetch.vst : ifetch.vhdl fifo_32b.vst
	vasy -I vhdl -V -o -a -p ifetch.vhdl ifetch

ifetch_model_o.vbe : ifetch.vst ifetch_model.vbe 
	boom -V ifetch_model ifetch_model_o

ifetch_model.vst : ifetch_model_o.vbe
	boog ifetch_model_o ifetch_model

mem.vbe : mem.vhdl
	vasy -I vhdl -V -o -a -p mem.vhdl mem

mem_o.vbe : mem.vbe 
	boom -V mem mem_o

mem.vst : mem_o.vbe
	boog mem_o mem

arm_core.vst : arm_core.vhdl
	vasy -I vhdl -V -o -a arm_core.vhdl arm_core

arm_chip.vst : arm_chip.vhdl
	vasy -I vhdl -V -o -a arm_chip.vhdl arm_chip

#sed "/ENTITY/i\library cells;\nuse cells.all;\n" ${nomf}.vhd > ${nomf}_net.vhdl

clean :
	rm *.vbe *.vst
