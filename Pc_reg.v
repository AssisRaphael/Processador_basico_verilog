module Pc_reg(in,incr,clock,wr_en,clear,out);


input [15:0]in;
input wr_en,incr,clock,clear;
output reg [15:0]out;

initial begin
		out<=0;
	end

always@(posedge clock)begin
	if(clear)
		out<=0;
	else if (wr_en)
		out<=in;
	else if(incr)
		out<=out+1;
	else
		out<=out;
end

endmodule