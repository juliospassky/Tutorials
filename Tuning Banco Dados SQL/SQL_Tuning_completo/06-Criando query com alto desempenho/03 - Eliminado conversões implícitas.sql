/*
Eliminando conversões implícitas.

- Conversões implícitas são quando o SQL Server realiza internamente conversões 
  de tipos de dados entre colunas dentro de uma expressão e que não são visíveis ao usuário. 

  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/data-types/data-type-conversion-database-engine?view=sql-server-2017

- Essas conversões implícitas entre tipos de dados acontece de acordo com regras de precedência

  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-2017

  A lista de precedência de tipos de dados são:

      UDT (tipos de dados definidos pelo usuário) (maior)
      sql_variant
      xml
      datetimeoffset
      datetime2
      datetime
      smalldatetime
      date
      time
      float
      real
      decimal ou numeric
      money
      smallmoney
      bigint
      int
      smallint
      tinyint
      bit
      ntext
      text
      imagem
      timestamp
      uniqueidentifier
      nvarchar [incluindo nvarchar(max)]
      nchar
      varchar [incluindo varchar(max)]
      char
      varbinary [incluindo varbinary(max)]
      binary (mais baixo)

- Dependendo de como ocorre a conversão implícita, uma expressão SARG pode virar uma expressão
  NoSARG e causar queda de desempenho na query.

- A regra geral aqui é os dados da expressões sempre do mesmo tipo e tamanho .

*/
use DBDemo
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente smallint not null identity(1,1) ,
   cNome varchar(100), 
   cCPF char(14),
   Constraint PKCliente Primary key 
   (
      iidCliente 
   )
)
go


insert into tCliente (cNome, cCPF)
select top 32767 cNome, cCPF from eCommerce.dbo.tCliente
go

set statistics profile on 

Select * from tCliente where iidCliente = 2     -- Tinyint 
Select * from tCliente where iidCliente = 255   -- Tinyint 
Select * from tCliente where iidCliente = 256   -- Smallint 
Select * from tCliente where iidCliente = 50000


set statistics profile off


/*
Mas nesses casos não precisa fazer nada. A conversão está do lado do valor da expressão.
A pesquisa é uma SARG.
*/


/*
Conversões entre tipos caracteres e números. 

- É comum armazenar dados somente número em colunas CHAR ou VARCHAR. 
  Casos em que os dados tem tamanho fixo e não efetuam qualquer tipo de cálculo,
  em certos casos acabam sendo armazenados em colunas string. 

  Conversamos sobre isso na aula "Tipos de Dados, Domínio e armazenamento" na sessão de Conceitos.

- Mas temos que tomar um cuidado quando realizamos uma pesquisa e desconhecemos a estrutura das
  tabelas e não respeitamos os tipos de dados. 

- Expressões de pesquisa onde os tipos de dados são diferentes, ocorre a conversão implícita de 
  acordo com a precedência dos tipos de dados, que pode levar a uma expressão NoSARG.

*/
use eCommerce
go

sp_helpindex2 tCliente
go

Create Index idxCPF on tCliente (cCPF) on INDICESTRANSACIONAIS

set statistics io  on 
go

Select * from tCliente
where cCPF = 71375968870   
go
set statistics io  off
go


/*
cCPF é uma coluna do tipo CHAR(14) e o número do cpf informado na expressão está sendo considerado
como NUMERIC(11).

Como a precedência do tipo númerico é maior do que o tipo caracter, o SQL Server converte implícitamente 
a coluna cCPF para NUMERIC(12).

Como se fosse igual a: 

 */

Select * from tCliente
where cast(cCPF as numeric(11))= 71375968870   
go

/*
Neste caso, converter a expressão NoSARG para SARG 
*/

set statistics io  on 
go
Select * from tCliente
where cCPF = '71375968870'
go
set statistics io  off 
go


/*
Conversões Ocultas 
*/

set statistics profile on 

Declare @dMovimento1 datetime = '2018-05-18'

Select COUNT(1) as nQtdMovimento  
  From tMovimento
 Where dMovimento >= @dMovimento1

Declare @dMovimento2 datetime2 = '2018-05-18'

Select COUNT(1) as nQtdMovimento  
  From tMovimento
 Where dMovimento >= @dMovimento2

set statistics profile off 

/*
Regra aqui e utilizar a variável do mesmo tipo e tamanho da coluna.
*/


/*
Tratar money como se fosse money.
*/



Select sum(mPreco) as mPreco 
from tItemMovimento
where iIDMovimento = 45865
and mPreco > 100
go



Select sum(mPreco) as mPreco 
from tItemMovimento
where iIDMovimento =  45865
and mPreco > 100.00
go



Select sum(mPreco) as mPreco 
from tItemMovimento
where iIDMovimento =  45865
and mPreco > $100.00


/*
Conversões em JOIN

- Não costumo ver conversões implícitas em JOIN em tabelas que tem integridade referencial 
  pela PK e FK.
  Quando se define um FK, as colunas das colunas envolvidas devem ser do mesmo tipo de dados.

- Mas quando o JOIN é realizado em colunas que não tem essa integridade ou quando 
  temos que tratar dados em tabelas temporárias de dados importados. 
  
*/

use eCommerce
go

sp_helpindex2 tProduto


/*
A tabela de produto precisa ser atualizada no Preco a partir de uma tabela de dados de importação
tProduto_Importacao 
A chave de pesquisa nessa tabela de importação é a coluna cCodigoExterno e ela deve ser utilizada
para encontrar os produtos na tabela tProduto.

Antes de atualizar o preco, voce deve realizar uma lista para comparar esses produtos e preços. 

Atenção:
Abir o arquivom 03a - Apoio Conversões Implícitas.sql 
e execute seun conteúdo.


*/
set statistics io on 
go



Select tProduto.iIDProduto, tProduto.cTitulo, tProduto.nPreco, 
       tProdutoImportacao.cTitulo, tProdutoImportacao.nPreco
  From tProduto 
  join tProdutoImportacao01 as tProdutoImportacao
    on tProduto.cCodigoExterno = tProdutoImportacao.cCodigoExterno 
    where tProdutoImportacao.cCodigoExterno like '8%'

 go



Select tProduto.iIDProduto, tProduto.cTitulo, tProduto.nPreco, 
       tProdutoImportacao.cTitulo, tProdutoImportacao.nPreco
  From tProduto 
  join tProdutoImportacao02 as tProdutoImportacao
    on tProduto.cCodigoExterno = tProdutoImportacao.cCodigoExterno 
    where tProdutoImportacao.cCodigoExterno like '8%'

 go


/*
Regra. As colunas do join devem ser sempre do mesmo tipo e tamanho. 
*/

/*
Erros de Conversão 
*/

Select * from tCliente
where cCelular = '802168902'

/*
Observando o plano de execução estimado, o SQL Server converte a coluna celular que é CHAR
para o dado que está do lado direito, que no caso é 802168902 do tipo INT.

Com isso, todos os dados dessa coluna são convertido para INT e o SQL Server avalida 
a expressão. Quando encontra o dados '19145 0581' e tenta converter para INT, apresenta o erro.
*/

select CAST('19145 0581' as int)


/*
Apresentar o valor do estoque por categoria .
*/

select top 10 * from tProduto 
go


Select iIDCategoria , sum(nPreco * nEstoque ) as nValorEstoque 
  From tProduto 
 Where nEstoque > 0 
 Group by iIDCategoria


Select nPreco, nEstoque  , nPreco*nEstoque as nValorEstoque
  From tProduto 
 Where iIDProduto = 2 


/*
nPreco é SMALLMONEY com precisão 10 e escala 4 -> (10,4) e
nEstoque é INT.

Como a ordem de Precedência é converter INT para SMALLMONEY, 
o resultado será SMALLMONEY.
*/

Select nPreco, nEstoque    from tProduto where iIDProduto = 2 

Select 928.52 * 288  -- > 267413.76

/*
O resultado é 267.413,76 .
É o limite para smallmoney e 214.748,3647.
Então temos a mensagem de erro . 
*/

Select nPreco, nEstoque , nPreco * cast(nEstoque as decimal(10))  from tProduto where iIDProduto = 2 
Select nPreco, nEstoque , cast(nPreco as decimal(10,4)) * nEstoque   from tProduto where iIDProduto = 2 


Select iIDCategoria , cast(sum( nPreco * nEstoque ) as decimal(10,4)) as nValorEstoque 
  From tProduto 
 Where nEstoque > 0 
 Group by iIDCategoria


Select iIDCategoria , sum( nPreco * cast(nEstoque as numeric(10,4)))  as nValorEstoque 
  From tProduto 
 Where nEstoque > 0 
 Group by iIDCategoria




Drop table if exists tProdutoImportacao01; 
Drop table if exists tProdutoImportacao02; 
Drop table if exists tProdutoImportacao; 

