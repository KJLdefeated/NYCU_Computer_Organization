module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o, Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o, MemtoReg_o);
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output	[2-1:0]	RegDst_o, MemtoReg_o;
output			Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o;
 
//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire	[2-1:0]	RegDst_o, MemtoReg_o;
wire			Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o;

//Main function
/*your code here*/
assign RegWrite_o = (instr_op_i == 6'b001000 || instr_op_i == 6'b000000 || instr_op_i == 6'b100001 || instr_op_i == 6'b001111)? 1'b1 : 1'b0;
assign ALUSrc_o=(instr_op_i==6'b000000 || instr_op_i==6'b111011 || instr_op_i==6'b100101)?0:1;
assign ALUOp_o = 	(instr_op_i == 6'b000000) ? 3'b010 : //R type
                    (instr_op_i == 6'b001111) ? 3'b101 : //lui 
					(instr_op_i == 6'b001000) ? 3'b011 : //addi
					(instr_op_i == 6'b111011) ? 3'b001 : //beq
					(instr_op_i == 6'b100101) ? 3'b110 : //bne
                    (instr_op_i == 6'b100001 || instr_op_i == 6'b100011) ? 3'b000 : //lw sw
					3'bxxx;
assign RegDst_o =   (instr_op_i == 6'b000000) ? 2'b01 : 2'b00; //r type
assign Branch_o =   (instr_op_i == 6'b111011 || instr_op_i == 6'b100101) ? 1'b1 : 1'b0; //beq, bne
assign BranchType_o =   (instr_op_i == 6'b100101) ? 1'b1 : 1'b0; //bne
assign Jump_o = 	(instr_op_i == 6'b100010) ? 1'b1 : 1'b0; //Jump
assign MemRead_o = 	(instr_op_i == 6'b100001 || instr_op_i == 6'b001111) ? 2'b01 : 2'b00; //lw
assign MemWrite_o = (instr_op_i == 6'b100011) ? 1'b1 : 1'b0; //sw
assign MemtoReg_o = (instr_op_i == 6'b100001) ? 2'b01 : 2'b00; //lw
endmodule
   