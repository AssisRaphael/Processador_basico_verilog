# Processador básico em verilog
Este repositório contém um processador básico feito em Verilog HDL

O processador realiza instruções simples como as operações lógicas básicas (and, or e not), adição e subtração, operações em memória (load e store), cópia de valores, cómpia condicional e copia de instrução. Para desenvolver o processador utilizamos os módulos registrador, multiplexador, unidade lógica e arimética e banco de registradores desenvolvidos anteriormente. O principais pontos trabalhados nessa prática foram as etapas de execução das instruções, o que será explicado com mais detalhes na próxima seção. A arquitetura desenvolvida utiliza uma palavra de 16 bits que descreve uma instrução a ser executada. E se tratando de instruções, a palavra segue o formato mostrado na tabela a seguir.


| Índice      | 15     | 11     | 8      | 5      | 0      |
|-------------|--------|--------|--------|--------|--------|
| Significado | Opcode | addr x | addr y | addr z | \-     |
| Complemento | 4 bits | 3 bits | 3 bits | 3 bits | 3 bits |


## Processador
O processador realiza suas intruções em etapas. Para representar isso, utilizou-se o conceito de máquina de estados onde, neste caso, há 4 estados possíveis. Em cada um desses estados diferentes parâmetros de controle serão enviados para cada um dos módulos que compõem o processador. Na primeira etapa, o processador deve pegar a instrução e armazená-la em um registrador de instruções, além disso, o PC deve ser incrementado de 1 para pegar a próxima instrução. Na segunda etapa, a instrução será decodificada a partir de seu opcode. Com isso, os endereços dos registradores serão salvos de acordo com a instrução e o PC não será incrementado, ou seja, nenhuma instrução será pega nesse momento. Na terceira etapa, os controles da ULA e do MUX serão estabelecidos de acordo com a instrução. É nessa etapa que novos dados serão gerados como, por exemplo, o resultado de uma soma ou de uma comparação. Todas as instruções, com excessão do store, terminam na terceira etapa, pois é nela que o banco de registradores é atualizado e os registradores internos a ele recebem os valores calculados ou encaminhados no passo anterior. A quarta e última etapa, é utilizada apenas pelo store que modificará a posição de memória com o valor recebido do dado que está em um registrador. Como as operações em uma determinada etapa da instrução demoram um ciclo de clock para serem realizadas, só consiguiremos ver o resultado de uma etapa no passo seguinte a ela. Por exemplo, só conseguiremos ver a alteração no banco de registradores a partir da quarta etapa.

## Memória
A memória possui 32 campos de 16 bits. Basicamente, o módulo recebe um determindado endereço, um dado para ser escrito e um habilita escrita. Dessa forma, pode-se ler e/ou escrever em qualquer posição de memória. Ela pode armazenar dados e instruções na forma de palavras de 16 bits. Para facilitar algumas simulações, valores foram pré-estabelecidos para algumas posições de memória.
