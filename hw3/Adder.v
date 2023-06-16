module Adder( src1_i, src2_i, sum_o	);

//I/O ports
input	[32-1:0] src1_i;
input	[32-1:0] src2_i;
output	[32-1:0] sum_o;

//Internal Signals
wire	[32-1:0] sum_o;
    
//Main function
/*your code here*/
wire tmp1, tmp2;
ALU a(.result(sum_o), .zero(tmp1), .overflow(tmp2), .aluSrc1(src1_i), .aluSrc2(src2_i), .ALU_operation_i(4'b0010));

endmodule
