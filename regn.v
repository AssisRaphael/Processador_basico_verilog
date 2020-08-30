/*
Recebe um R de 16 bits, um habilita leitura, o clock e forbece uma saida de 16 bits 
*/
module regn(R, Rin, Clock, Q);
	parameter n = 16;
	input [n-1:0] R;
	input Rin, Clock;
	output reg [n-1:0] Q;
	
	initial begin
		Q<=0;
	end
	
	always @(posedge Clock)
		if (Rin)
			Q <= R;
endmodule
