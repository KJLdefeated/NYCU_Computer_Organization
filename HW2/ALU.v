module ALU( result, zero, overflow, aluSrc1, aluSrc2, invertA, invertB, operation );
   
  	output wire[31:0] result;
  	output wire zero;
  	output wire overflow;

  	input wire[31:0] aluSrc1;
  	input wire[31:0] aluSrc2;
  	input wire invertA;
  	input wire invertB;
  	input wire[1:0] operation;
	
  	/*your code here*/
  	wire [31:0] w_result;
  	wire w_cout;
  	wire zero_;
  	wire [31:0] carry_temp;
  	wire set;

  	assign zero_ = 1'b0;

  	wire w_cin_lastbit;
  	wire w_overflow;
  	assign w_cin_lastbit = ((invertB==1&&operation==2'b10) || operation==2'b11) ? 1:0;
	ALU_1bit a0(.result(w_result[0]), .carryOut(carry_temp[0]), .a(aluSrc1[0]), .b(aluSrc2[0]), .invertA(invertA), .invertB(invertB), .operation(operation), .carryIn(w_cin_lastbit), .less(set));
	
	genvar idx;
	generate
	for (idx = 1; idx <= 31; idx = idx + 1)
	begin
		ALU_1bit a1(.result(w_result[idx]), .carryOut(carry_temp[idx]), .a(aluSrc1[idx]), .b(aluSrc2[idx]), .invertA(invertA), .invertB(invertB), .operation(operation), .carryIn(carry_temp[idx-1]), .less(zero_));
	end
	endgenerate

  	xor (overflow, carry_temp[31], carry_temp[30]);
	wire last_sum, last_ctmp;
	Full_adder a2(.sum(last_sum), .carryOut(last_ctmp), .carryIn(carry_temp[30]), .input1(aluSrc1[31]), .input2(aluSrc2[31]));
	assign set = (overflow==1'b1) ? (last_sum) : (last_sum) ? 1'b0 : 1'b1;

	assign result = w_result;
	assign zero=(result==32'b0)?1:0;
endmodule