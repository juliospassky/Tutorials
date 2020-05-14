/*
Uma das formas de você identificar se uma query é lenta ou não é 
avaliando o quanto ela consumo de páginas de dados e recursos do servidor.

Você consegue esses valores usando uma das ferramentas e recursos abaixo:

 - Profiler
 - Extend Events
 - Usando DMVs
 - Estatisticas de Acesso e Tempo
 - Performance Monitor

Nessa aula, vamos ver como usar o editor de query para obter no momento
da execução da consultas, esses valores.

SET STATISTICS IO 

Quando ligado e uma instrução é executada, o SQL Server apresenta as estatísticas 
de acesso ao cache ou buffer ou a área de disco.

set statistics io on -- Ligar a apresentação
set statistics io off -- Desligar a apresentação

*/

set statistics io on

set statistics io off

/*
Quais dados são apresentados: 

Para cada tabela envolvida na instrução, é apresenta uma linha 
com as informações de estatísticas. São elas:

Table 'XXXXXXXX'		Nome da Tabela 
Scan count           Contagem de buscas para recuperar os dados.
logical reads			Páginas acessadas no Buffer Pool (cache de dados).
physical reads       Páginas acessadas do Disco.
read-ahead reads		Páginas incluídas no Buffer Pool. Chamda leitura antecipada.

Outras informações contidas no resultado são referentes a dados LOB (Large Object ou 
tipo de dados para grandes objetos) como varchar(max) ou varbinary(max). 
São eles lob logical reads, lob physical reads e lob read-ahead reads. 
LOB serão tratados em uma seção específica.
*/



/*
SET STATISTICS TIME  

Quando ligado e uma instrução é executada, o SQL Server apresenta as estatísticas 
de:

- Tempo de Análise da instrução 
- Tempo de Compilação 
- Tempo de CPU no servidor 

set statistics time on -- Ligar a apresentação
set statistics time off -- Desligar a apresentação


*/

use DBDemo
go

Drop table if exists DBDemo.dbo.tCliente 

/*
Cria uma tabela 
*/

Select 
       iIDCliente, iIDEstado, cNome, cCPF, cEmail, 
       cCelular, dCadastro, dNascimento, cLogradouro, 
       cCidade, cUF, cCEP,  dDesativacao, mCredito 
  Into tCliente 
  From eCommerce.dbo.tCliente 

/*
Carregando uma linha da tabela clientes 
*/

set statistics io on
set statistics time on 
go

DBCC DROPCLEANBUFFERS 
go
DBCC FREEPROCCACHE 
go


Select * 
  From tCliente
 Where iIDCliente = 199617 

 /*
SQL Server parse and compile time: 
   CPU time = 200 ms, elapsed time = 200 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(1 row affected)
Table 'tCliente'. Scan count 1, logical reads 4016, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 65 ms.

 */

 use eCommerce
 go



 select tCliente.cNome,   tProduto.cTitulo , 
        sum(tItemMovimento.nQuantidade * tItemMovimento.mPreco) as mValor , count(tMovimento.iIDMovimento) as mQtdMovimento
   from tMovimento
   join tCliente 
     on tMovimento.iIDCliente = tCliente.iIDCliente
   join tItemMovimento
     on tMovimento.iIDMovimento = tItemMovimento.iIDMovimento
   join tProduto  
     on tItemMovimento.iIDProduto = tProduto.iIDProduto
  group by tCliente.cNome , tProduto.cTitulo
  order by tCliente.cNome  , tProduto.cTitulo



/*
SQL Server parse and compile time: 
   CPU time = 15 ms, elapsed time = 121 ms.

(59214 rows affected)

Table 'tProduto'. Scan count 3, logical reads 5474, physical reads 0, read-ahead reads 37, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tMovimento'. Scan count 3, logical reads 1044, physical reads 0, read-ahead reads 453, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tCliente'. Scan count 3, logical reads 4122, physical reads 0, read-ahead reads 4006, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 4884, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tItemMovimento'. Scan count 3, logical reads 4356, physical reads 2, read-ahead reads 4049, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 9797 ms,  elapsed time = 11325 ms.


*/



 