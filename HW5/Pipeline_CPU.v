module Pipeline_CPU( clk_i, rst_n );

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
wire [5-1:0] ShamtSrc;
wire [5-1:0] MEM_EX_Write_reg;
wire [32-1:0] PC_add1, PC_add2, PC_no_jump, PC_t, Mux3_result, DM_ReadData;
wire Jr;
wire [32-1:0] WB_Data;
//reg jal
wire [5-1:0] Jal_Write_reg;
wire [32-1:0] Jal_WB_Data;
wire Jal;
wire [32-1:0] IF_instr;
wire [2-1:0] ID_RegDst;
wire ID_RegWrite;
wire [3-1:0] ID_ALUOp;
wire ID_ALUSrc;
wire ID_MemWrite;
wire ID_MemRead;
wire [2-1:0] ID_MemtoReg;
wire [32-1:0] ID_rs_data;
wire [32-1:0] ID_rt_data;
wire [32-1:0] ID_sign_instr;
wire [32-1:0] ID_zero_instr;
wire [32-1:0] ID_IF_instr;
wire EX_ID_RegWrite;
wire EX_ID_MemWrite;
wire EX_ID_MemRead;
wire [2-1:0] EX_ID_MemtoReg;
wire [32-1:0] EX_Write_Data;
wire [32-1:0] EX_ID_rt_data;
wire [5-1:0] EX_Write_reg;
wire [2-1:0] MEM_EX_ID_MemtoReg;
wire [32-1:0] MEM_EX_Write_Data;
wire [32-1:0] MEM_MemReadData;
wire MEM_EX_ID_RegWrite;
assign Jr = ((instr[31:26] == 6'b000000) && (instr[20:0] == 21'd8)) ? 1 : 0;
//modules
//IF
Program_Counter PC(.clk_i(clk_i),.rst_n(rst_n),.pc_in_i(PC_add1),.pc_out_o(PC_o));
Adder Adder1(.src1_i(PC_o), .src2_i(32'd4),.sum_o(PC_add1));
Instr_Memory IM(.pc_addr_i(PC_o),.instr_o(instr));
//IF/ID
Pipeline_Reg #(.size(32)) Pipeline_IM( .clk_i(clk_i),.rst_i(rst_n),.data_i(instr),.data_o(IF_instr));
//ID
Reg_File RF(.clk_i(clk_i),.rst_n(rst_n),.RSaddr_i(IF_instr[25:21]),.RTaddr_i(IF_instr[20:16]),.Wrtaddr_i(MEM_EX_Write_reg),.Wrtdata_i(WB_Data),.RegWrite_i(MEM_EX_ID_RegWrite & (~Jr)),.RSdata_o(ReadData1),.RTdata_o(ReadData2));
Decoder Decoder(.instr_op_i(IF_instr[31:26]),.RegWrite_o(RegWrite),.ALUOp_o(ALUOP),.ALUSrc_o(ALUSrc),.RegDst_o(RegDst),.Jump_o(Jump),.Branch_o(Branch),.BranchType_o(BranchType),.MemWrite_o(MemWrite),.MemRead_o(MemRead),.MemtoReg_o(MemtoReg));
Sign_Extend SE(.data_i(IF_instr[15:0]),.data_o(signextend));
Zero_Filled ZF(.data_i(IF_instr[15:0]),.data_o(zerofilled));
//ID/EX
Pipeline_Reg #(.size(11)) Pipeline_Control( .clk_i(clk_i),.rst_i(rst_n),.data_i({RegWrite, ALUOP, ALUSrc, RegDst, MemRead, MemWrite, MemtoReg}),.data_o({ID_RegWrite, ID_ALUOp, ID_ALUSrc, ID_RegDst, ID_MemRead, ID_MemWrite, ID_MemtoReg}));
Pipeline_Reg #(.size(32)) Pipeline_RS( .clk_i(clk_i),.rst_i(rst_n),.data_i(ReadData1),.data_o(ID_rs_data));
Pipeline_Reg #(.size(32)) Pipeline_RT( .clk_i(clk_i),.rst_i(rst_n),.data_i(ReadData2),.data_o(ID_rt_data));
Pipeline_Reg #(.size(32)) Pipeline_SE( .clk_i(clk_i),.rst_i(rst_n),.data_i(signextend),.data_o(ID_sign_instr));
Pipeline_Reg #(.size(32)) Pipeline_ZF( .clk_i(clk_i),.rst_i(rst_n),.data_i(zerofilled),.data_o(ID_zero_instr));
Pipeline_Reg #(.size(32)) Pipeline_IM_ID_EX( .clk_i(clk_i),.rst_i(rst_n),.data_i(IF_instr),.data_o(ID_IF_instr));
//EX
Mux3to1 #(.size(5)) Mux_Write_Reg(.data0_i(ID_IF_instr[20:16]),.data1_i(ID_IF_instr[15:11]),.data2_i(5'd31),.select_i(ID_RegDst),.data_o(WriteReg_addr));
ALU_Ctrl AC(.funct_i(ID_IF_instr[5:0]),.ALUOp_i(ID_ALUOp),.ALU_operation_o(ALU_operation),.FURslt_o(FURslt));
Mux2to1 #(.size(32)) ALU_src2Src(.data0_i(ID_rt_data),.data1_i(ID_sign_instr),.select_i(ALUSrc),.data_o(ALUinput2));
Mux2to1 #(.size(5)) Shamt_Src(.data0_i(ID_IF_instr[10:6]),.data1_i(ID_rs_data[5-1:0]),.select_i(ALU_operation[1]),.data_o(ShamtSrc));
ALU ALU(.aluSrc1(ID_rs_data),.aluSrc2(ALUinput2),.ALU_operation_i(ALU_operation),.result(ALUResult),.zero(zero),.overflow(overflow));
Shifter shifter( .result(ShifterResult),.leftRight(ALU_operation[0]),.shamt(ShamtSrc),.sftSrc(ALUinput2));
Mux3to1 #(.size(32)) RDdata_Source(.data0_i(ALUResult),.data1_i(ShifterResult),.data2_i(ID_zero_instr),.select_i(FURslt),.data_o(WriteData));
//EX/MEM
Pipeline_Reg #(.size(5)) Pipeline_Control_EX( .clk_i(clk_i),.rst_i(rst_n),.data_i({ID_RegWrite, ID_MemRead, ID_MemWrite, ID_MemtoReg}),.data_o({EX_ID_RegWrite, EX_ID_MemRead, EX_ID_MemWrite, EX_ID_MemtoReg}));
Pipeline_Reg #(.size(32)) Pipeline_Write_Data( .clk_i(clk_i),.rst_i(rst_n),.data_i(WriteData),.data_o(EX_Write_Data));
Pipeline_Reg #(.size(32)) Pipeline_RT_EX( .clk_i(clk_i),.rst_i(rst_n),.data_i(ID_rt_data),.data_o(EX_ID_rt_data));
Pipeline_Reg #(.size(5)) Pipeline_Write_reg( .clk_i(clk_i),.rst_i(rst_n),.data_i(WriteReg_addr),.data_o(EX_Write_reg));
//MEM
Data_Memory DM(.clk_i(clk_i),.addr_i(EX_Write_Data),.data_i(EX_ID_rt_data),.MemRead_i(EX_ID_MemRead),.MemWrite_i(EX_ID_MemWrite),.data_o(DM_ReadData));
//MEM/WB
Pipeline_Reg #(.size(3)) Pipeline_Control_MEM( .clk_i(clk_i),.rst_i(rst_n),.data_i({EX_ID_RegWrite, EX_ID_MemtoReg}),.data_o({MEM_EX_ID_RegWrite, MEM_EX_ID_MemtoReg}));
Pipeline_Reg #(.size(32)) Pipeline_Write_Data_MEM( .clk_i(clk_i),.rst_i(rst_n),.data_i(EX_Write_Data),.data_o(MEM_EX_Write_Data));
Pipeline_Reg #(.size(32)) Pipeline_MEM_Data( .clk_i(clk_i),.rst_i(rst_n),.data_i(DM_ReadData),.data_o(MEM_MemReadData));
Pipeline_Reg #(.size(5)) Pipeline_Write_reg_MEM( .clk_i(clk_i),.rst_i(rst_n),.data_i(EX_Write_reg),.data_o(MEM_EX_Write_reg));		
//WB
Mux3to1 #(.size(32)) WB_Mux(.data0_i(MEM_EX_Write_Data),.data1_i(MEM_MemReadData),.data2_i(32'd0),.select_i(MEM_EX_ID_MemtoReg),.data_o(WB_Data));
endmodule



