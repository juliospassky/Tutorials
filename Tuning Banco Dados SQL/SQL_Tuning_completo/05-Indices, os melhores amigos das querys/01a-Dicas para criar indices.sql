/*
Entenda as características das consultas mais usadas

Entenda as características das colunas usadas nas consultas.
  - tipo de dados de inteiro e, também, colunas exclusivas ou não nulas

Determine o melhor local de armazenamento para o índice.

Números grandes de índices em uma tabela afetam o desempenho das instruções INSERT,
UPDATE, DELETE e MERGE 

Tabelas pequenas não são boas para ter índices.

Utilize indice não clusterizado para pesquisas mais frequentes
Utilize indices clusterizado para chave primária, com numeração sequencial e crescente.

Chaves estrangeiras são fortes candidatas a ter índices. 

Avalie o uso de indices de cobertura. 

Quanto menor for o comprimento de uma chave de índice melhor. Colunas do tipo INT são as
melhores para se criar uma chave de índice. 

Inclua na chave somente as colunas que são pesquisáveis.  

Utilize a seletividade das colunas.
   - Colunas altamente seletivas, tende a ter uma repetição de dados baixa. Colunas 100% seletivas, tem dados
     exclusivos. São ótimas candidatas a ter um índices. A coluna CPF em uma tabela de cadastros de pessoas físicas
	 é um exemplo. 
   - Colunas com baixa seletividade possuem um maior número de dados repetidos. Não são eficientes quando fazem
     parte da primeira chave de um índice. Devido ao grande numeros de dados, o SQL SERVER escolha em varrer todos
	 o indice do que fazer a pesquisa pela chave. A coluna SEXO em uma tabela de cadastro de pesssoas físicas é
	 um exemplo. 

Em um índice composto, seleciona a ordem com que as colunas serão criadas em um chave de acordo com pesquisa. 


	



*/