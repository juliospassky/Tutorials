/*
Índice em colunas calculadas.

- O retorno da coluna deve ser determinística
- Não pode ser do tipo REAL,FLOAT, TEXT, NTEXT ou IMAGE

*/

use eCommerce
go

sp_helpindex2 tItemMovimento
go

drop index if exists idxMovimento  on tItemMovimento
drop index if exists idxFKProduto on tItemMovimento
drop index if exists idxCheckSumDescricao on tProduto
go
Alter table tItemMovimento drop column mValor
Alter table tProduto drop column nCheckSumDescricao
Alter table tCliente drop column cNomeReverso

/*
Seguindo o exemplo da aula anterior, vamos criar a coluna calculada
mValor com base na multiplicação de nQuantidade e mPreco. 
*/

Alter table tItemMovimento add mValor as nQuantidade * mPreco 
go
/*
*/
sp_help tItemMovimento
go


set statistics io  on 
-- Ativar plano de execução

Select iIDItem, nQuantidade, mPreco, mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
   and mValor > 4500

-- Table 'tItemMovimento'. Scan count 1, logical reads 34442, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.


/*
Criamos um índice de cobertura com a coluna calculada.
*/

Create Index IDXMovimento 
          on tItemMovimento (iIDMovimento,mValor) 
     include (nQuantidade, mPreco, iidProduto) 
        with (drop_existing=on)

go

/*
*/
Select iIDItem, nQuantidade, mPreco, mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
   and mValor  > 4500

-- Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

/*
Colocando a coluna como persistida.
*/

drop index if exists IDXMovimento on tItemMovimento
go
Alter table tItemMovimento drop column mValor 
go
Alter table tItemMovimento add mValor as nQuantidade * mPreco persisted 
go


Create Index IDXMovimento 
     on tItemMovimento (iIDMovimento,mValor) 
include (nQuantidade, mPreco, iidProduto) 
go


Select iIDItem, nQuantidade, mPreco, mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
  and mValor  > 4500

-- Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

/*
Criando índice para colunas VARCHAR(MAX)  
*/

sp_help tProduto 
go

Select top 10 * from tProduto
go

Create Index idxDescricao on tProduto (cDescricao) 
go
-- ??

/*
Existe uma função no SQL Server chamada BINARY_CHECKSUM() que gera um valor de soma de verificação
de uma dados ou de uma lista. 
*/

Select BINARY_CHECKSUM('SQL SERVER 2017')
Select BINARY_CHECKSUM('sql server 2017')

/*
Vamos definir uma coluna calculada que será um checksum da coluna cDescricao 
*/

Alter table tProduto 
        add nCheckSumDescricao as binary_checksum(cDescricao) persisted
go



Declare @cDescricao varchar(max) 
Declare @nCheckSumDescricao int 

set @cDescricao = 'consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris id sapien.'
set @nCheckSumDescricao = binary_checksum(@cDescricao)

Select * 
  From tProduto 
 Where cDescricao = @cDescricao 
    
Select * 
  From tProduto 
 Where nCheckSumDescricao = @nCheckSumDescricao
go


/*
Criando os índices 
*/
Create Index idxDescricao on tProduto (cDescricao)
-- Ops!!!
go

Create Index idxCheckSumDescricao on tProduto (nCheckSumDescricao)
go


Declare @cDescricao varchar(max) 
Declare @nCheckSumDescricao int 

set @cDescricao = 'consectetuer, cursus et, magna. Praesent interdum ligula eu enim. Etiam imperdiet dictum magna. Ut tincidunt orci quis lectus. Nullam suscipit, est ac facilisis facilisis, magna tellus faucibus leo, in lobortis tellus justo sit amet nulla. Donec non justo. Proin non massa non ante bibendum ullamcorper. Duis cursus, diam at pretium aliquet, metus urna convallis erat, eget tincidunt dui augue eu tellus. Phasellus elit pede, malesuada vel, venenatis vel, faucibus id, libero. Donec consectetuer mauris id sapien.'
set @nCheckSumDescricao = binary_checksum(@cDescricao)

Select * 
  From tProduto 
 Where cDescricao = @cDescricao 
    
Select * 
  From tProduto 
 Where nCheckSumDescricao = @nCheckSumDescricao
go


/*
Realizando pesquisa pelo sobrenome do Cliente

Nesse exemplo, precisamos realizar pesquisas considerando 
sobrenome dos clientes. 

Sem entrar no mérito da modelagem de dados, se esse dados deveria ficar
em duas colunas, como Nome e Sobrenome.

*/
use eCommerce
go

sp_helpindex tCliente

drop index if exists idxNome on tCliente
drop index if exists idxNomeReverso on tCliente

set statistics io on 

Select iidCliente, cNome  from tCliente 
where cNome like '% Moore'

/*
Vamos criar um índice pela coluna nome e vamos analisar o comportamento.
*/
Create Index idxNome on tCliente (cNome)
go

Select iidCliente, cNome  from tCliente 
where cNome like '% Moore'


/*
Criar coluna calculada com o nome do cliente no sentido contrário.

Mason M. Moore  -- erooM .M nosaM

Select * from tCliente 
where cNomeReverso like 'erooM%'

Utiliza a função REVERSE para gerar uma coluna calculada 

*/

Alter Table tCliente 
        add cNomeReverso as REVERSE(cNome) persisted
go

Select iidCliente, cNome  from tCliente 
where cNomeReverso like 'erooM%'
go

/*
Criar um índice com a coluna cNomeReverso
*/
Create Index idxNomeReverso on tCliente (cNomeReverso)
go

Select iidCliente, cNome  from tCliente 
where cNomeReverso like 'erooM%'
go

Create Index idxNomeReverso 
          on tCliente (cNomeReverso) 
     include (cNome) 
        with (drop_existing = on )


Select iidCliente, cNome  from tCliente 
where cNomeReverso like 'erooM%'
go



