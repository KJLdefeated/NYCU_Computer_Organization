module ALU_1bit( result, carryOut, a, b, invertA, invertB, operation, carryIn, less ); 
  
  output wire result;
  output wire carryOut;
  
  input wire a;
  input wire b;
  input wire invertA;
  input wire invertB;
  input wire[1:0] operation;
  input wire carryIn;
  input wire less;
  
  /*your code here*/ 
  wire temp_a, temp_b;
  wire or_temp, and_temp;
  wire temp1, temp2, sum;
  reg temp;
  assign result=temp;

  /*Operations*/
  xor a_invert(temp_a, invertA, a);
  xor b_invert(temp_b, invertB, b);
  and ANDgate(and_temp, temp_a, temp_b);
  or ORgate(or_temp, temp_a, temp_b);

  /*Adder*/
  xor AxorB(temp1, temp_a, temp_b);
  xor xorcin(sum, temp1, carryIn);
  and cout_step1(temp2, temp1, carryIn);
  or carryout(carryOut, temp2, and_temp);

  always @(*) begin
    case(operation)
    2'b00:temp = or_temp;
    2'b01:temp = and_temp;
    2'b10:temp = sum;
    2'b11:temp = less;
    endcase
  end
  
  
endmodule