VERILOG = iverilog
TARGET = ALU.vcd

$(TARGET) : ALU
	vvp ALU

ALU.vvp: 
	$(VERILOG) -o ALU TestBench.v ALU.v Shifter.v ALU_1bit.v ALU_lsb.v

clean:
	rm $(TARGET)