//Modulo principal
//Controlador

//HEX7 HEX6 - Instrução
//HEX5 HEX4 - RegX
//HEX3 HEX2 - RegY
//HEX1 HEX0 - Resultado
//SW[15:0] - Dado entrada (Instrução)
//key0 - clock

//Os dados são lidos diretamente da memória
//As instruções são carregadas para a memória no momento de inicialização pelo arquivo mif

module Processador(SW, KEY, LEDR, LEDG, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0); 
  input [17:0] SW;
  input [3:0] KEY;
  output reg [17:0] LEDR;
  output [8:0] LEDG;
  output [0:6] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
  wire [15:0] Barramento, ADDR, Saida;
  wire [15:0] DadoEntradaInstrucao, DadoEntradaDados;
  reg [15:0] DadoEntrada;
  wire [2:0] Passo;
  wire [1:0] SelecionaMemoria;
  wire Resetn, Clock, Run, W, Done;

  assign Clock = KEY[0];//Recebe o sinal de clock
  assign Resetn = KEY[1];
  assign Run = KEY[2];
  assign LEDG[0] = Clock;//Indica pulso de clock
  assign LEDG[1] = Done;//Registra que a instrução terminou
  
  //Seleciona de qual memória o dado será lido
  
  ramlpmDados MemoriaDados(ADDR, Clock, Saida, W, DadoEntradaDados);//Cria o modulo da memoria RAM de 64 x 16bits
  ramlpm MemoriaInstrucao(ADDR, Clock, Saida, 0, DadoEntradaInstrucao);//Cria o modulo da memoria RAM de 64 x 16bits
  
  //Proc(DadoEntrada, Resetn, Clock, Run, Done, Barramento, Addr, Saida, W, Passo);
  Proc proc(DadoEntrada, Resetn, Clock, Run, Done, Barramento, ADDR, Saida, W, Passo, SelecionaMemoria);//Cria o módulo processador
  
  display_7seg H0 (Barramento[3:0], HEX0);
  display_7seg H1 (Barramento[7:4], HEX1);
  display_7seg H2 (Barramento[11:8], HEX2);
  display_7seg H3 (Barramento[15:12], HEX3);
  display_7seg H4 (ADDR[3:0], HEX4);
  display_7seg H5 (ADDR[7:4], HEX5);
  display_7seg H6 (ADDR[11:8], HEX6);
  display_7seg H7 (ADDR[15:12], HEX7);
   
  always@(posedge Clock)begin
  
		case(SelecionaMemoria)
			2'b00: DadoEntrada <= DadoEntradaInstrucao;
			2'b01: DadoEntrada <= DadoEntradaDados;
			2'b10: DadoEntrada <= SW[15:0];
		
		endcase
	
		if (SW[17])
			LEDR[15:0] = DadoEntrada;
		else
			LEDR[15:0] = Saida;
  end
  
endmodule
