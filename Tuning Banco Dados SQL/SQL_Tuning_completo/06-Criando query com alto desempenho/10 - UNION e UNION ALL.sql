/*
Utilizando UNION ou UNION ALL 

- A instrução UNION realiza a união horizontal de linhas de duas instruções
  SELECT. 

- Para executar essa instrução você tem que observar algumas regras:
  
   - A quantidade de colunas das instruções SELECT devem ser iguais;
   - Os tipos de dados das colunas que serão unidas devem ser, preferencialmente,
     do mesmo tipo e tamanho;

   Se os tipos forem diferentes, o SQL Server utiliza as conversões implícitas e para alguns
   cenário podem ocorre erro de conversão, conforme visto na aula "Eliminando conversões implícitas".

*/

use eCommerce
go

Select count(1) from tCliente
Select count(1) from tEmpresa

/*
199519
100000
*/

Select cLogradouro, cCidade, cUF, cCEP from tCliente
union 
Select cLogradouro, cCidade, cUF, cCEP from tEmpresa
go

/*
Para os próximos exemplos, carregue o arquivo
10a - Apoio UNION x UNION ALL.sql e execute todo o conteúdo.
*/

use eCommerce
go

/*
-- Conversões Implícitas 
*/


/*
No processo de união das linhas, se as colunas que serão associadas forem de
tipos de dados diferentes, o SQL Server realizará as conversões implícitas.

Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-2017

*/

Select count(1) from tProduto
Select count(1) from tProdutoImportacao03
Select count(1) from tProdutoImportacao04

/*
100000
100
100
*/


set statistics io on 

Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union 
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao03

-- Sem conversão 
Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union 
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao04

set statistics io off


/*
-- Diferenças entre UNION e UNION ALL
*/

-- Union elimina a duplicidade de dados

Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao04
go

-- Union ALL preserve os dados
Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union all
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao04
go


/*
Otimizando um query, trocando o operador OR pelo UNION ALL
*/

sp_helpindex2 tMovimento


 Create Index idxDataValidade 
     on tMovimento (dValidade,dMovimento) 
include (iidcliente) 
with (drop_existing=on)
     on indicestransacionais


set statistics io on

declare @dData date = '2018-05-17'

Select dValidade , dMovimento, iIDCliente, iIDMovimento  
  From tMovimento 
 Where (dValidade= @dData or dValidade is null)
   and dMovimento >= '2018-04-17'

Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where dValidade= @dData 
  and dMovimento >= '2018-04-17'
union all
Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where dValidade is null
  and dMovimento >= '2018-04-17'

set statistics io off


