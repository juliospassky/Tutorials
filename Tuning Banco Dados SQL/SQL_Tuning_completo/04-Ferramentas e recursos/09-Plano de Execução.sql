/*
Preparando o ambiente
*/

use eCommerce

Drop Index if exists idxNome on tCliente
Drop Index if exists idxCPF on tCliente
Drop Index if exists idxCategoria on tPRoduto
Alter table tProduto drop constraint PKProduto 


Create Index idxCPF on tCliente (cCPF)
Create Index idxCategoria on tProduto (iidcategoria)
Alter table tProduto add constraint PKProduto Primary Key (iidproduto)


sp_helpindex tProduto



/*
Plano de execução  

- Plano de execução de uma consulta (Execution Plan) e o resultado de como o 
  Otimizador de Consulta calculou a maneira mais eficiente entre várias formas 
  de acessar o dados. 
  Um plano de execução pode ser visualizado em uma representação gráfica ou textual,
  apresentando as etapas físicas e a ordem como são executadas de acesso ao dados. 

- Quando uma consulta enviada por um aplicação chega no gerenciador de banco de dados, ela passa
  por algumas etapas antes do retorno dos dados. São as seguintes etapas:
  
  	- Análise ou Parse
	  
	  Primira etapa executada quando a query chega no gerenciador de banco de dados é verificar
	  se a forma como a instrução foi montada está correta. Se a forma da consultar estiver errada,
	  o gerenciador retorna uma mensagem de erro. Caso contrário, ele monta uma árvore de análise ou
	  árvore de consulta quer será enviada para a próxima etapa.

*/
use eCommerce
go

Select iidCliente cNome cCPF fron tCliente  
 Where iIDCliente == 199617 

Select iidCliente, cNome, cCPF fron tCliente  
 Where iIDCliente == 199617 
 
Select iidCliente, cNome, cCPF from tCliente  
 Where iIDCliente == 199617 

Select iidCliente, cNome, cCPF from tCliente  
 Where iIDCliente = 199617 



/*
	- Algebrizer

	  Essa etapa recebe da etapa anterior a árvore de consulta e realiza a resolução de todos os nomes
	  de todos os objetos, como as tabelas e colunas. Sintaxe como  "SELECT * FROM" será ajusta colocando
	  todas as colunas da tabela no lugar do asterisco. Esse proceso gera um binário chamado árvoce de 
	  processador de query e envia para a próxima etapa. 
*/

use eCommerce
go

Select iD, cNome, cCPF from Cliente  
 Where iiIDCliente = 199617 

Select iD, cNome, cCPF from tCliente  
 Where iiIDCliente = 199617 

Select iIDCliente, cNome, cCPF from tCliente  
 Where iIDCliente = 199617 


/*

	- Otimizador de Consultas

	   Recebe o Query Processor Tree e tentar identificar as várias alternativas para resolver a consulta,
	   considerando sempre o menor custo de processamento. Para as consultas simples, o Otimizador tem um
	   número reduzido de alternativas, devido a pouca quantidade de objetos e predicados que
	   serão avaliados. 
	   
	   Mas em consultas complextas, onde temos diversas tabelas, com vários filtros
	   e agregações, as alternativas de resolver a query são tantas, que o tempo de análise pode ser maior
	   que o tempo de execução a própria query. Então o Otimizador limita o número de tentativas e as 
	   vezes não consegue identificar a melhor forma.

	   As vezes o Otimizador de consulta pode identificar um predicado e o seu respectivo índice, mas
	   a quantidade de linhas que será retornada pode fazer com que o custo de processamento seja maior
	   do quer fazer um verradura completa na tabela. Neste caso o Otimizador gera um plano de execução
	   para realizar um Table Scan. 

      O Otimizador gera o plano de execução em um formato binário, armazena o plano no Plan Cache 
      (Cache de Plano de execução) e envia para a próxima fase.

   - Execução 

	  Nessa última etapa, temos a execução do plano de execução que é recebido pelo 
     mecanismo de armazenamento que executará a query conforme o plano. 

*/

use eCommerce
go

set statistics xml on 

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

set statistics xml off
 
 


/*
Visualizar Plano de Execução Estimado e Plano de Execução Real. 

- Plano de execução Estimado.
  - Representa os valores fornecidos pelo Otimizador de Consulta.
  - Ele não executa a consulta
  - Selecione a consulta e pressione CTRL+L
*/

use eCommerce
go

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

/*
- Plano de execução Real.
  - Representa os valores pela execução do plano.
  - Ele somente é obtido quando voce executa a instrução.
  - Pressione CTRL+M para ativar e novamente para desativar 

Os Planos estimado e real, em geral apresentam os mesmos valores. Mas dependendo
de como a fase de execução trata o plano de execução, ela pode realizar ajustes
para a execução e os planos podem ser diferentes. 

*/

use eCommerce
go

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

/*
Interpretação da visualização do Plano de Execução 

- Leitura é da Direita para a Esquerda e de Cima para Baixo 
- Cada objeto representado são chamados de Operadores.
- As setas entre os operadores representam o fluxo de dados e
  sua espessura reprenta a quantidade de linhas. 
- O texto abaixo do Operador identifica:
   - O nome do Operador
   - O objeto de alocação de dados 
   - O custo (estimado ou real) em percentual do desse operador em 
     relação ao plano de execução.
*/

/*
Executando duas solicitações e realizando comparações 
*/

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

Select iidCliente, cNome, cCPF from tCliente  
 Where cast(cCPF as bigint) = 43303122842
 
/*
Alguns operadores que podemos evitar

- Table Scan
- Index Scan 
- Sort
- RID Lookup (Heap)
- Compute Scalar 
*/

Select * from tEmpresa
where iidEmpresa = 1

Select iidProduto,cTitulo from tProduto where iIDCategoria = 12

Select * from tMovimento 
   join tCliente 
   on tMovimento.iidcliente = tCliente.iIDCliente
where cCodigo = 'CB75A0'
order by dMovimento 



Select nQuantidade*mPreco from tItemMovimento where iIDMovimento = 1587


Select nQuantidade,mPreco from tItemMovimento where iIDMovimento = 1587


--------------------------------------------------------------------------------------------------------------
/*
Observando o Cache de Planos.

- Todos os planos de consulta que são gerandos, ficam armazenados em um espaço da memória 
  chamado Cache de Planos (Plan Cache). 
- Quando o otimizado gera um plano estimado, ele compara com os planos de execução que estão
  no Plan Cache. Se encontrar um plano idêntico, ele reaproveita esse plano sem a necessidade de
  criar um plano de execução real.
- Plano de execução não ficam para sempre no Plan Cache. A medida que passa o tempo, eles são 
  eliminados. 

- Podemos visualizar dados do Plan Cache com a DMV sys.dm_exec_cached_plans
  Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-cached-plans-transact-sql?view=sql-server-2017

*/

use eCommerce
go
Select * 
  From sys.dm_exec_cached_plans CachedPlans

/*
Colunas relavantes :

   - Usecounts - Número de vezes que o objeto do cache foi referenciado.
   - Size_in_Bytes - Bytes consumido pelo objeto do cache.
   - Cacheobjtype - Tipo do objeto no cache.
   - Objtype   - Tipo de objeto 
         - Proc - Procedure
         - Adhoc - Consultas SQL 
   - Plan_handle - Identificador do plano na memória.
*/

/*
Limpa todo o Plan Cache
*/

DBCC FREEPROCCACHE
go

Select * 
  From sys.dm_exec_cached_plans CachedPlans

/*
Observando a entrada de uma consulta no Plan Cache 
*/

Select * from tProduto where iIDProduto = 83838
go
Select * from tProduto where iIDProduto = 5666
go

/*

*/
Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- Não 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'



/*

*/
DBCC FREEPROCCACHE
go


declare @iid int = 83838
Select * from tProduto where iIDProduto = @iid --Teste
go
declare @iid int =5666
Select * from tProduto where iIDProduto = @iid --Teste


Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- Não 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'


/*

*/
DBCC FREEPROCCACHE
go


declare @iid int = cast(rand()*100004 as int)+1
Select * from tProduto where iIDProduto = @iid --Teste
go
declare @iid int = cast(rand()*100004 as int)+1
Select * from tProduto where iIDProduto = @iid --Teste


Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- Não 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'


/*
Examinando a execução de uma Store Procedure 
*/


Create or Alter Procedure stp_ConsultaProduto 
@id int
as
begin

  Select * 
    From tProduto 
   Where iIDProduto = @id --Teste

end 
go


DBCC FREEPROCCACHE
go


stp_ConsultaProduto  5666
go
stp_ConsultaProduto  83838


Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- Não 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'

/*
*/

