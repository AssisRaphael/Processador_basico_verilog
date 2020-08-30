/*
	A cada sinal de clock, se clear = 1 ele retorna zero e se clear = 0 retorna Q++;
*/
module upcount(Clear, Clock, Q);
	input Clear, Clock;
	output reg [2:0] Q;
	always @(posedge Clock)
		if (Clear)
			Q <= 3'b0;
		else
			Q <= Q + 1'b1;
endmodule
