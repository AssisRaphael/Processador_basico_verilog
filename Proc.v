//Módulo de processamento de dados
// Instruções: LD, ST, MVNZ, MV, MVI, ADD, SUB, AND, SLT, SLL, SRL
module Proc(DadoEntrada, Resetn, Clock, Run, Done, Barramento, Addr, Saida, W_D, Passo, SelecionaMemoria);
	input [15:0] DadoEntrada;//Dado de Entrada (DIN)(16 bits)
	input Resetn;
	input Clock;//Clock 
	input Run;//Registra que a instrução está em execução
	output reg Done;//Registra que a instrução terminou
	output reg [15:0] Barramento;//(BusWires)
	output [15:0] Addr, Saida;//(ADDR e DOUT) Endereço memória e dado saida
	output reg W_D;//Habilita escrita na memória
	output [2:0] Passo;//Passo (Tstep_Q)
	output reg[1:0] SelecionaMemoria;
	
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7 /*PC*/, resultado;//Registradores (Dados)
	wire [15:0] A, G;//Registradores A e G
	reg Ain, Gin;//Habilita a entrada dos registradores A, G
	reg Aout, Gout;//Habilita a saida dos registradores A, G
	reg HabilitaSaida;//(DOUTin) habilita a saida
	reg IncrementaPc;//(incr_pc) Habilita incemprenta pc
	reg HabilitaAddr;//(ADDRin) Habilita ler ou escrever em endereço
	reg SelecionaDadoEntrada;//(DINout) Habilita o dado de entrada
	reg HabilitaInstrucao;//(IRin) Habilita ler a instrução
	wire [3:0] I;//Tipo da instrução
	wire [9:0] IR;//Instrução completa enviada para ser executada
	reg [7:0] SaidaRegistradores, EntradaRegistradores;//(Rout, Rin) Entradas e saidas dos registradores
	reg [9:0] ControleMux;//(MUXsel)
	reg [2:0] ControleUla;//Configura a ULA
	reg [7:0] HabilitaRegs;//Habilita os registradores de R0-R7
	wire [7:0] Xreg, Yreg;//Habilitam os registradores

	
	wire Clear = Done | ~Resetn;//Reseta o Passo (Tstep_Q) quando a instrução acabar ou quando der stall
	upcount Tstep(Clear, Clock, Passo);//Ajusta o Passo (0 1 2 3 0 1 ...)
	assign I = IR[3:0];//I recebe o tipo da instrução
	dec3to8 decX(IR[6:4], 1'b1, Xreg);//Habilita o registrador RX
	dec3to8 decY(IR[9:7], 1'b1, Yreg);//Habilita o registrador RY
	
	
	
	always @(Passo or I or Xreg or Yreg)begin
		//Inicia variáveis
		HabilitaInstrucao = 0;
		SaidaRegistradores[7:0] = 0;//Saidas zeradas
		EntradaRegistradores[7:0] = 0;//Entradas zeradas
		SelecionaDadoEntrada = 0;//Não lê nada
		Ain = 0;//Não escreve nada
		Gout = 0;//Não escreve nada
		Gin = 0;//Não lê nada
		ControleUla = 0;//Soma
		HabilitaSaida = 0;//Não escreve nada
		HabilitaAddr = 0;//Não escreve nada
		W_D = 0;//Não habilita nada
		IncrementaPc = 0;//Não Pula pra proxima instrução
		Done = 0;//Reseta o done
		SelecionaMemoria = 1;//Lê dados
		
		case (Passo)//Para cada passo, faça:
			3'b000: //Passo 0 
				begin //Habilita ler a instrução e habilita os registradores
				   SaidaRegistradores = 10'b10000000;
					SelecionaMemoria = 0;
					W_D = 0;//Não habilita nada
					HabilitaAddr = 1;//Habilita ler dado 
					//IncrementaPc = 1;//Lê proxima instrução
					SelecionaMemoria = 0;//Le instruções
				end
			3'b001: //Passo 1 
				begin //Lê instrução
					HabilitaInstrucao = 1;//Lê a instrução
					SelecionaMemoria = 0;
					HabilitaAddr = 1;//Lê a instrução
				end
			3'b010: begin//Passo 2 
				SelecionaMemoria = 1;
				HabilitaInstrucao = 0;//Não Lê a instrução
				case (I)//Execute a instrução
					4'b0000: 
						begin //MV - Copia regX para RegY
							SaidaRegistradores = Yreg;//Habilita ler no regY
							EntradaRegistradores = Xreg;//Habilita escrever o regX
						end//MV
					4'b0001: //MVI - Copia um valor numérico para regX
						begin 
							SelecionaMemoria = 2;
						end//MVI
					4'b0010://ADD - Soma dois números
						begin 
							Ain = 1;//Habilita escrever no regA
							SaidaRegistradores = Xreg;//Habilita ler o regX
							ControleUla = 0;
						end//ADD
					4'b0011://SUB - Subtrai dois números
						begin 
							Ain = 1;//Habilita escrever no regA
							SaidaRegistradores = Xreg;//Habilita ler o regX
							ControleUla = 1;
						end//SUB
					4'b0100://LD - Lê um valor da memória
						begin //Copia o endereço do dado para Saida
							SaidaRegistradores = Yreg;//Habilita ler o regY
							HabilitaAddr = 1;//Habilita ler o endereço
						end//LD
					4'b0101://ST - Escreve um dado na memória
						begin 
							SaidaRegistradores = Xreg;//Habilita ler o regX
							HabilitaSaida = 1;//Habilita a saida de dados do processador
						end//ST
					4'b0110://MVNZ - Move if not zero
						begin 
							if (G != 0) begin//Se G for diferente de zero
								SaidaRegistradores = Yreg;//Habilita ler no regY
								EntradaRegistradores = Xreg;//Habilita escrever o regX
							end
						end//MVNZ
					4'b0111: 
						begin//AND - Realiza um and bit a bit entre regX e regY
							Ain = 1;//Habilita escrever no regA
							SaidaRegistradores = Xreg;//Habilita ler o regX
							ControleUla = 5;
						end//AND
					4'b1000: 
						begin//SLT - Retorna 1 se regX < regY e 0 caso contrario
							Ain = 1;//Habilita escrever no regA
							SaidaRegistradores = Xreg;//Habilita ler o regX
							ControleUla = 2;
						end//SLT
					4'b1001: 
						begin//SLL - regX = regX << regY
							Ain = 1;//Habilita escrever no regA
							SaidaRegistradores = Xreg;//Habilita ler o regX
							ControleUla = 3;
						end//SLL
					4'b1010: 
						begin 
							Ain = 1;//Habilita escrever no regA
							SaidaRegistradores = Xreg;//Habilita ler o regX
							ControleUla = 4;
						end//SRL
				endcase
			end
			3'b011: //Passo 3
				case (I)
					4'b0000: 
						begin //MV - Copia regX para RegY
							Done = 1'b1;//Instrução Pronta
							IncrementaPc = 1;//Lê proxima instrução
						end//MV
					4'b0001: //MVI - Copia um valor numérico para regX
						begin 
							SelecionaDadoEntrada = 1;//Seleciona o dado da entrada (Imediato)
							EntradaRegistradores = Xreg;//Habilita escrever o regX
						end//MVI
					4'b0010: 
						begin//ADD
						    Ain = 0;
							SaidaRegistradores = Yreg;//Copia o regY para a ULA
							Gin = 1;//Armazena a soma no regG
							ControleUla = 0;
						end//ADD
					4'b0011: 
						begin//SUB
							Ain = 0;
							SaidaRegistradores = Yreg;//Copia o regY para a ULA
							Gin = 1;//Armazena a subtração no regG
							ControleUla = 1;//Configura a ULA para subtração
						end//SUB
					4'b0100: 
						begin//LD 
							//Considera que o dado da memória vem pelo DIN nesse passo
							SelecionaDadoEntrada = 1;//Lê dado
							EntradaRegistradores = Xreg;//Habilita escrever no regX
							HabilitaAddr = 0;
						end//LD
					4'b0101: 
						begin//ST
							HabilitaSaida = 0;
							SaidaRegistradores = Yreg;//Le dado do regY
							HabilitaAddr = 1;//Habilita acessar a memória
							W_D = 1;//Habilita escrever na memória
						end//ST
					4'b0110://MVNZ - Move if not zero
						begin 
							Done = 1'b1;//Instrução terminada
							IncrementaPc = 1;//Lê proxima instrução
						end//MVNZ
					4'b1000: 
						begin//SLT
							Ain = 0;
							SaidaRegistradores = Yreg;//Copia o regY para a ULA
							Gin = 1;//Armazena a subtração no regG
							ControleUla = 2;//Configura a ULA para slt
						end//SLT
					4'b1001: 
						begin//SLL
							Ain = 0;
							SaidaRegistradores = Yreg;//Copia o regY para a ULA
							Gin = 1;//Armazena a subtração no regG
							ControleUla = 3;//Configura a ULA para sll
						end//SLL
					4'b1010: 
						begin//SRL 
							Ain = 0;
							SaidaRegistradores = Yreg;//Copia o regY para a ULA
							Gin = 1;//Armazena a subtração no regG
							ControleUla = 4;//Configura a ULA para slr
						end//SRL
					4'b0111: 
						begin//AND 
							Ain = 0;
							SaidaRegistradores = Yreg;//Copia o regY para a ULA
							Gin = 1;//Armazena a subtração no regG
							ControleUla = 5;//Configura a ULA para AND
						end//AND
				endcase
			3'b100: //Passo 4
			begin
				HabilitaInstrucao = 0;
				case (I)
					4'b0001: //MVI - Copia um valor numérico para regX
						begin 
							Done = 1'b1;//Instrução Pronta
							IncrementaPc = 1;//Lê proxima instrução
						end//MVI
					4'b0010: 
						begin//ADD
							Gin = 0;
							Gout = 1;//Lê resultado da soma
							EntradaRegistradores = Xreg;//Habilita escrever em regX
							ControleUla = 0;

						end//ADD
					4'b0011: 
						begin//SUB 
						    Gin = 0;
							Gout = 1;//Lê resultado da subtração
							EntradaRegistradores = Xreg;//Habilita escrever em regX
							ControleUla = 1;

						end//SUB
					4'b0100: 
						begin//LD 
							Done = 1;//Instrução concluida
							IncrementaPc = 1;
						end//LD
					4'b0101: 
						begin//ST
							Done = 1;//Instrução concluida
							IncrementaPc = 1;
						end//ST
					4'b1000: 
						begin//SLT 
						    Gin = 0;
							Gout = 1;//Lê resultado da SLT
							EntradaRegistradores = Xreg;//Habilita escrever em regX
							ControleUla = 2;

						end//SLT
					4'b1001: 
						begin//SLL 
						    Gin = 0;
							Gout = 1;//Lê resultado da SLL
							EntradaRegistradores = Xreg;//Habilita escrever em regX
							ControleUla = 3;

						end//SLL
					4'b1010: 
						begin//SRL 
						    Gin = 0;
							Gout = 1;//Lê resultado da SRL
							EntradaRegistradores = Xreg;//Habilita escrever em regX
							ControleUla = 4;
						end//SRL
					4'b0111: 
						begin//AND 
						    Gin = 0;
							Gout = 1;//Lê resultado da AND
							EntradaRegistradores = Xreg;//Habilita escrever em regX
							ControleUla = 5;
						end//AND
				endcase
			end
			3'b101: //Passo 5
			begin
				Done = 1;
				IncrementaPc = 1;
			end
		endcase
	end
	
  //Instancia os registradores
  regn reg_0 (Barramento, EntradaRegistradores[0], Clock, R0);
  regn reg_1 (Barramento, EntradaRegistradores[1], Clock, R1);
  regn reg_2 (Barramento, EntradaRegistradores[2], Clock, R2);
  regn reg_3 (Barramento, EntradaRegistradores[3], Clock, R3);
  regn reg_4 (Barramento, EntradaRegistradores[4], Clock, R4);
  regn reg_5 (Barramento, EntradaRegistradores[5], Clock, R5);
  regn reg_6 (Barramento, EntradaRegistradores[6], Clock, R6);
  Pc_reg reg_7(Barramento, IncrementaPc, Clock, EntradaRegistradores[7],~Resetn, R7);
  
  regn reg_IR (DadoEntrada, HabilitaInstrucao, Clock, IR);//Copia o dado de entrada para o registrador IR
  regn reg_A (Barramento, Ain, Clock, A);
  regn reg_G (resultado, Gin, Clock, G);
  regn reg_ADDR (Barramento,HabilitaAddr, Clock, Addr);//Copia o barramento para a saida addr
  regn reg_DOUT (Barramento, HabilitaSaida, Clock, Saida);
  
  //Chama ULA
  ULA ula(ControleUla, A, Barramento, resultado);
  
  //Controla MUX
  always @ (ControleMux or SaidaRegistradores or Gout or SelecionaDadoEntrada or EntradaRegistradores)
  begin
    ControleMux[9:2] = SaidaRegistradores;
    ControleMux[1] = Gout;
    ControleMux[0] = SelecionaDadoEntrada;
    
    case (ControleMux)
      10'b0000000001: Barramento <= DadoEntrada;
      10'b0000000010: Barramento <= G;
      10'b0000000100: Barramento <= R0;
      10'b0000001000: Barramento <= R1;
      10'b0000010000: Barramento <= R2;
      10'b0000100000: Barramento <= R3;
      10'b0001000000: Barramento <= R4;
      10'b0010000000: Barramento <= R5;
      10'b0100000000: Barramento <= R6;
      10'b1000000000: Barramento <= R7;
    endcase
  end
endmodule
