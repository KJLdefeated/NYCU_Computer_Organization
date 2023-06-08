module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signles
wire [32-1:0] instr, PC_i, PC_o, ReadData1, ReadData2, WriteData;
wire [32-1:0] signextend, zerofilled, ALUinput2, ALUResult, ShifterResult;
wire [5-1:0] WriteReg_addr, Shifter_shamt;
wire [4-1:0] ALU_operation;
wire [3-1:0] ALUOP;
wire [2-1:0] FURslt;
wire [2-1:0] RegDst, MemtoReg;
wire RegWrite, ALUSrc, zero, overflow;
wire Jump, Branch, BranchType, MemWrite, MemRead;
wire [32-1:0] PC_add1, PC_add2, PC_no_jump, PC_t, Mux3_result, DM_ReadData;
wire Jr;
assign Jr = ((instr[31:26] == 6'b000000) && (instr[20:0] == 21'd8)) ? 1 : 0;

//modules
//IF
Program_Counter PC(
        .clk_i(clk_i),
	    .rst_n(rst_n),
	    .pc_in_i(PC_i),
	    .pc_out_o(PC_o)
	    );

Adder Adder1(//next instruction
        .src1_i(PC_o), 
	    .src2_i(32'd4),
	    .sum_o(PC_add1)
	    );
Instr_Memory IM(
        .pc_addr_i(PC_o),
	    .instr_o(instr)
	    );

/*always@(PC_o)
begin
    $display("pc_o: %b", PC_o);
	$display("pc+4: %b", PC_add1);
end
*/		
Adder Adder2(//branch
        .src1_i(PC_add1),
	    .src2_i({signextend[29:0], 2'b00}),//shift left 2
	    .sum_o(PC_add2)
	    );

Mux2to1 #(.size(32)) Mux_branch(
        .data0_i(PC_add1),
        .data1_i(PC_add2),
        .select_i(Branch & (zero ^ BranchType)),
        .data_o(PC_no_jump)
        );
/*always@(*)
begin
    $display("pc_add1: %b", PC_add1);
	$display("pc_add2: %b", PC_add2);
	$display("pc_no_jump: %b", PC_no_jump);
end*/

Mux2to1 #(.size(32)) Mux_jump(
        .data0_i(PC_no_jump),
        .data1_i({PC_add1[31:28], instr[25:0], 2'b00}),//jump address
        .select_i(Jump),
        .data_o(PC_t)
        );
		
Mux2to1 #(.size(32)) Mux_jr(// deal with jr
        .data0_i(PC_t),
        .data1_i(ReadData1),
        .select_i(Jr),
        .data_o(PC_i)
        );


/*always@(*)
begin
    $display("PC_o: %b", PC_o);
	$display("instr: %b", instr);
end*/
Mux3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr[20:16]),
        .data1_i(instr[15:11]),
		.data2_i(5'd31),// jal
        .select_i(RegDst),
        .data_o(WriteReg_addr)
        );	
	
Reg_File RF(
        .clk_i(clk_i),
	    .rst_n(rst_n),
        .RSaddr_i(instr[25:21]),
        .RTaddr_i(instr[20:16]),
        .RDaddr_i(WriteReg_addr),
        .RDdata_i(WriteData),
        .RegWrite_i(RegWrite & (~Jr)),// consider jr
        .RSdata_o(ReadData1),
        .RTdata_o(ReadData2)
        );

Decoder Decoder(
        .instr_op_i(instr[31:26]),
	    .RegWrite_o(RegWrite),
	    .ALUOp_o(ALUOP),
	    .ALUSrc_o(ALUSrc),
	    .RegDst_o(RegDst),
		.Jump_o(Jump),
		.Branch_o(Branch),
		.BranchType_o(BranchType),
		.MemWrite_o(MemWrite),
		.MemRead_o(MemRead),
		.MemtoReg_o(MemtoReg)
		);

ALU_Ctrl AC(
        .funct_i(instr[5:0]),
        .ALUOp_i(ALUOP),
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt)
        );

	
Sign_Extend SE(
        .data_i(instr[15:0]),
        .data_o(signextend)
        );
/*always@(*)
begin
	$display("signextend: %d", signextend);
end*/
Zero_Filled ZF(
        .data_i(instr[15:0]),
        .data_o(zerofilled)
        );
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(ReadData2),
        .data1_i(signextend),
        .select_i(ALUSrc),
        .data_o(ALUinput2)
        );	
/*
Mux2to1 #(.size(32)) Shifter_in( //srl sll sllv srlv
        .data0_i({27'd0,instr[10:6]}),//fill to 32 bit
        .data1_i(ReadData1),
        .select_i(ALU_operation[1]),
        .data_o(Shifter_shamt)
        ); // Shifter_shamt would cause warning(Mux output: 32b, shifter shamt: 5b)
*/
ALU ALU(
		.aluSrc1(ReadData1),
	    .aluSrc2(ALUinput2),
	    .ALU_operation_i(ALU_operation),
		.result(ALUResult),
		.zero(zero),
		.overflow(overflow)
	    );
/*always@(*)
begin
	$display("ReadData1: %d", ReadData1);
	$display("ALUinput2: %d", ALUinput2);
	$display("ALUResult: %d", ALUResult);
end*/
Shifter shifter( 
		.result(ShifterResult),
		.leftRight(ALU_operation[0]),
		.shamt(instr[10:6]),
		.sftSrc(ALUinput2)
		);

Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(ALUResult),
        .data1_i(ShifterResult),
		.data2_i(zerofilled),
        .select_i(FURslt),
        .data_o(Mux3_result)
        );			
/*always@(*)
begin
	$display("ALUResult: %d", ALUResult);
	$display("FURslt: %d", FURslt);
	$display("Mux3_result: %d", Mux3_result);
end*/
Data_Memory DM(
		.clk_i(clk_i),
		.addr_i(Mux3_result),
		.data_i(ReadData2),
		.MemRead_i(MemRead),
		.MemWrite_i(MemWrite),
		.data_o(DM_ReadData)
		);
/*always@(*)
begin
	$display("Mux3_result: %d", $signed(Mux3_result));
	$display("ReadData2: %d", $signed(ReadData2));
end*/	
Mux3to1 #(.size(32)) Mux_Write( 
        .data0_i(Mux3_result),
        .data1_i(DM_ReadData),
		.data2_i(PC_add1),//PC+4 consider jal
        .select_i(MemtoReg),
        .data_o(WriteData)
        );
/*always@(*)
begin
	$display("WriteData: d", WriteData);
end*/
endmodule



