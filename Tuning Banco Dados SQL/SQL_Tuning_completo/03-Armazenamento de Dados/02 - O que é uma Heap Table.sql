/*
Explicação.

A tabela DemoPage é uma Heap Table. Uma tabela que não tem índices clusterizado.

Como ela não tem índices para a coluna iIDCliente = 1, o SQL Server
precisar ler toda as páginas da tabela para encontrar a linha que
satisfação o predicado.

Mesmo que voce inclua os dados em uma ordem que deseja que eles fiquem, 
uma Heap Table não tem em sua estrutura os dados algo que indique que esses dados
estão ordenados.

Por isso que sempre uma pesquisa de dados lerão todas as páginas da tabela heap.

Quando utilizar uma Heap Table?

Tabelas pequenas com poucas linhas e colunas cuja a soma total de bytes que serão
armazenados for menor que 8060 bytes.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/heaps-tables-without-clustered-indexes

*/ 
