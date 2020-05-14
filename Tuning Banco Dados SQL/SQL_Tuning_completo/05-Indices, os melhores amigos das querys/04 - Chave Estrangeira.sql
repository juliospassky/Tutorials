/*
Chave Estrangeira.

O recurso da chave estrangeira na modelagem de dados garante que um tupla de uma entidade
se relaciona com um outra entidade que tem a chave primária.

A ocorrência de uma entidade somente existirá se a chave estrangeira dessa entidade 
se relacionar com a chave primária da outra entidade.

Quando falamos em SQL SERVER, a FK (abreviação de Foreign Key) pode ser uma coluna ou conjunto de colunas
que deve possuir o mesmo tipo e tamanho de dados da PK (abreviação de Primary Key) da tabela que manterá o 
relacionamento.

Mas o que isso tem relação com índice?

Quando criamos um relacionamento entre duas tabelas, em algum momento do código em SQL, utilizaremos os 
comandos de Junções (JOIN) para acessar dados de ambas as tabelas e o JOIN realizará a pesquisa na 
tabela com a PK e a FK.

De forma semelhante, quando utilizarmos os comandos UPDATE e DELETE na tabela que tem a PK, ocorrerá
uma consultas nas tabelas quem tem FK para garantir a integridade referencial. 

Então, se temos essas pesquisas e uma das tabelas tem uma PK que tem um índice clusterizado, um boa prática e 
criarmos um índice (clusterizado ou não clusterizado) para as colunas da FK de outra tabela.

*/
use eCommerce
go

sp_helpindex tProduto
go

sp_helpindex tItemMovimento
go
drop index if exists IDXFKProduto on tItemMovimento


/*
Criar uma PK para tProduto e para tItemMovimento 

- Como as tabelas já existem, vamos verificar se as colunas são próprias para PK

*/

Select top 10 * from tProduto


/*
Criar a PK
*/

Alter Table tProduto 
        add constraint PKProduto Primary Key (iidProduto) 
go
go


sp_helpindex 'tProduto'


/*
PK para ItemMovimento 
*/

Select top 10 * from tItemMovimento
go

Alter Table tItemMovimento 
        add constraint PKItemMovimento Primary key(iiDItem)
go

sp_helpindex 'tItemMovimento'
go

/*
A table tItemMovimento não tem chave estrangeira. 
*/

sp_fkeys  @fktable_name = 'tItemMovimento'
go

Alter Table tItemMovimento 
        add constraint FKProduto Foreign key (iidProduto) References tProduto(iidProduto)
go

sp_fkeys  @fktable_name = 'tItemMovimento'
go


/*
Diferente da PK, o fato de criar a FK não cria um índice com a colunas ou colunas.
*/

set statistics io on

Select tProduto.nPreco,
       tItemMovimento.iIDItem, 
       tItemMovimento.iIDMovimento, 
       tItemMovimento.nQuantidade, 
       tItemMovimento.mDesconto  
  From tProduto
  Join tItemMovimento 
    on tProduto.iIDProduto = tItemMovimento.iIDProduto
 where tItemMovimento.iIDProduto = 99911

set statistics io off

/*
Table 'tItemMovimento'. Scan count 1, logical reads 12384, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
Simulando a exclusão de uma linha da tabela tProduto. 
Nessa simulação, o produto existe na tabela tItemMovimento
e teremos um erro na execução. 
*/

set statistics io on
set statistics xml on

Delete tProduto where iIDProduto = 3078 

set statistics io off
set statistics xml off

/*
Nessa outra simulação, o produto Não existe na tabela tItemMovimento
e conseguiremos realizar a exclusão. 
*/

Insert into tProduto(iIDCategoria, cCodigo,cTitulo,cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque)
Select top 1 iIDCategoria, 'D9879-8268','Inativo',cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque
  From tProduto
go

Select top 1 * From tProduto order by iIDProduto desc
go

/*
*/

set statistics io on
set statistics xml on

Delete from tProduto where iIDProduto = 100008

set statistics io off
set statistics xml off

sp_helpindex tProduto


/*
Table 'tItemMovimento'. Scan count 1, logical reads 34443, physical reads 358, read-ahead reads 29698, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 10, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Select top 10 * from tItemMovimento order by NEWID()
go

set statistics io on 
update tItemMovimento set iIDProduto = 36803 where iIDItem = 523601
set statistics io off

/*
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tItemMovimento'. Scan count 0, logical reads 6, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
Criando um índice não clusterizado para a coluna iidProduto que é a chave da chave estrangeira 
FKProduto 
*/

sp_fkeys  @fktable_name = 'tItemMovimento'
go

Create Index IDXFKProduto on tItemMovimento (iidproduto) 

sp_helpindex tItemMovimento 
go


/*
*/
set statistics io on

Select tProduto.nPreco,
       tItemMovimento.iIDItem, 
       tItemMovimento.iIDMovimento, 
       tItemMovimento.nQuantidade, 
       tItemMovimento.mDesconto  
  From tProduto
  Join tItemMovimento 
    on tProduto.iIDProduto = tItemMovimento.iIDProduto
 where tItemMovimento.iIDProduto = 99911

set statistics io off

/*
Table 'tItemMovimento'. Scan count 1, logical reads 78, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
Simulando a exclusão de uma linha da tabela tProduto. 
Nessa simulação, o produto existe na tabela tItemMovimento.

*/

Delete tProduto where iIDProduto = 3078 


/*
Table 'tItemMovimento'. Scan count 1, logical reads 374, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/



/*
Nessa simulação, o produto Não existe na tabela tItemMovimento.
*/

Insert into tProduto(iIDCategoria, cCodigo,cTitulo,cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque)
select top 1 iIDCategoria, 'D9879-8268','Inativo',cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque
 From tProduto
go

Select top 1 * From tProduto order by iIDProduto desc
go

/*
*/

set statistics io on
set statistics xml on

Delete from tProduto where iIDProduto = 100009

set statistics io off
set statistics xml off

/*
Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 10, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
*/

Select top 10 * from tItemMovimento order by NEWID()




set statistics io on 
update tItemMovimento set iIDProduto = 98241 where iIDItem = 61465
set statistics io off
go

sp_helpindex tItemMovimento
go

sp_helpindex2 tItemMovimento
go

/*
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tItemMovimento'. Scan count 0, logical reads 22, physical reads 4, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- Ele tevem que atualizar 3 indices
-- E houve leitura de página maior que antes de ter o índice.

*/




/*
Devo então criar índices para todas as Foreign Key?
---------------------------------------------------

Quando criamos uma Foreing Key, já estamos assumindo que duas
tabelas terão relacionamentos e que em algum momento será feito
uma consulta que envolverá as duas tabelas. 

Também estamos assumindo que se ocorrer uma exclusão de uma linha na 
tabela "Pai", pela integridade referencial da PK/FK, a tabela "Filho"
(ou as tabelas) serão pesquisadas para verificar se essa integridade 
não será violada. Para isso, o SQL Server pesquisará a linha excluída
na tabela "Pai", na tabela "Filho". 

Quando devo criar um índice em uma FK?

- Quando a tabela "Pai" tem um grande incidência de DELETE e existe 
  muitas tabelas "Filhos" relacionadas pela FK. Então voce deve 
  criar os índices nas tabelas "Filhos".

- Se temos muitas consultas da tabela "Pai" relacionada com as tabelas 
  "Filho" usando JOIN com as colunas chave. Então voce deve 
  criar os índices nas tabelas "Filhos".

- Se a coluna da tabela Filho, que faz parta da FK,  tem alta seletividade. 
  Então voce deve criar os índices nessa tabela;

  

*/














