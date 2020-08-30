module ULA (ControleUla, x, y, Saida);
	input	[2:0] ControleUla;
	input  [15:0] x;
	input [15:0] y;
	output reg [15:0] Saida;
	
	always @(*)
	  begin	 
		 case (ControleUla)
			3'b000: 
				begin//add
					Saida = x + y;
				end
			3'b001: 
				begin//sub
					Saida = x - y;
				end
			3'b010: 
				begin//slt
					if(x<y)
						Saida = 1;
					else
						Saida = 0;
				end
			3'b011: 
				begin//sll
					Saida = x << y;
				end
			3'b100: 
				begin//srl
					Saida = x >> y;
				end
			3'b101: 
				begin//and
					Saida = x & y;
				end
		 endcase
	end
endmodule
