module ALU( aluSrc1, aluSrc2, ALU_operation_i, result, zero, overflow );

//I/O ports 
input	[32-1:0] aluSrc1;
input	[32-1:0] aluSrc2;
input	 [4-1:0] ALU_operation_i;

output reg	[32-1:0] result;
output wire		 zero;
output wire		 overflow;

//Internal Signals
//wire			 zero;
//wire			 overflow;
//wire	[32-1:0] result;

//Main function
/*your code here*/

always @(ALU_operation_i, aluSrc1, aluSrc2) begin
	case (ALU_operation_i)
		0: result <= aluSrc1 & aluSrc2;
		1: result <= aluSrc1 | aluSrc2;
		2: result <= aluSrc1 + aluSrc2;
		6: result <= aluSrc1 - aluSrc2;
		7: result <= $signed(aluSrc1) < $signed(aluSrc2) ? 1 : 0;
		12: result <= ~(aluSrc1 | aluSrc2);
		default: result <= 0;
	endcase
end
assign zero = (result==0);


endmodule
