/*
Índice composto.

- Quando temos uma query que utiliza duas expressões para o filtro das linhas e em cada expressão
  temos uma coluna utilizada para realizar uma parte da filtragem. 
  Temos no total, duas colunas que são utilizadas para realizar o filtro das linhas. 
  
- Podemos criar um índice que cobre as duas colunas e com isso acelara a pesquisa da query.

*/

use eCommerce
go

drop index if exists idxCategoria  on tProduto
drop index if exists idxCodigoExterno on tProduto
 

set statistics io on 
set statistics xml on

Select * 
  From tProduto 
 Where cCodigoExterno = '9821-7' 
   and iIDCategoria = 12 

set statistics io off
set statistics xml off


/*
(1 row affected)
Table 'tProduto'. Scan count 1, logical reads 5284, physical reads 0, read-ahead reads 1553, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Create Index idxCodigoExterno on tProduto (cCodigoExterno )
go

sp_helpindex tProduto 


set statistics io on 
set statistics xml on

Select * 
  From tProduto 
 Where cCodigoExterno = '9821-7' 
   and iIDCategoria = 12 

set statistics io off
set statistics xml off

/*
Table 'tProduto'. Scan count 1, logical reads 8, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

drop index idxCodigoExterno  on tProduto
go

Create Index idxCategoria on tProduto (iidCategoria) 
go

sp_helpindex tProduto
go


set statistics io on 
set statistics xml on

Select * 
  From tProduto 
 Where iIDCategoria = 12 
   and cCodigoExterno = '9821-7' 

set statistics io off 
set statistics xml off

/*
Table 'tProduto'. Scan count 1, logical reads 5284, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

/*
Existe neste caso uma questão sobre a Seletividade da coluna.

No caso da iIDCategoria ela apresenta uma baixa seletividade. Isto quer dizer
que os dados presentes nessa coluna são altamente repetidos. 

*/ 
 
Select iidCategoria , COUNT(1) from  tProduto
group by iidCategoria 
order by COUNT(1) desc 


Select cCodigoExterno, count(1) from tProduto
group by cCodigoExterno
order by count(1) desc 


/*
Veja um exemplo de um produto que tem o iIDCategoria = 19  
*/

Insert into tProduto(iIDCategoria, cCodigo,cTitulo,cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque)
select top 1 19, 'D9879-8268','Inativo',cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque
 From tProduto

set statistics io on 
set statistics xml on

Select * 
  From tProduto 
 Where iIDCategoria = 19 -- Existe apenas 1 linha na tabela para essa categoria 
   and cCodigoExterno = '89.564.33'


Select * 
  From tProduto 
 Where iIDCategoria = 12 -- Temos 5511 linhas para essa categoria 
   and cCodigoExterno = '9821-7' 

set statistics io off 
set statistics xml off

/*
Como podemos melhorar essa seletividade?

Incluíndo mais uma coluna na chave do indice, reduzindo a taxa de repetição na chave
e aumentando a seletividade dos dados. 
*/ 

Create Index idxCategoria on tProduto (iidCategoria, cCodigoExterno) with (drop_existing = on )

set statistics io on 
set statistics xml on

Select * 
  From tProduto 
 Where iIDCategoria = 19 -- Existe apenas 1 linha na tabela para essa categoria 
   and cCodigoExterno = '89.564.33'

Select * 
  From tProduto 
 Where cCodigoExterno = '9821-7' 
   and iIDCategoria = 12 

set statistics io off
set statistics xml off

/*

*/

sp_helpindex tItemMovimento
go

drop index if exists idxiIDMovimento on tItemMovimento
alter table tItemMOvimento drop constraint PKItemMovimento
alter table tItemMOvimento add constraint PKItemMovimento Primary Key (iIDItem)

set statistics io on 
set statistics xml on

select * from tItemMovimento 
where iIDProduto = 2570
  and iIDMovimento = 45361

select * from tItemMovimento 
where iIDProduto = 80491
  and iIDMovimento = 97088

set statistics io off
set statistics xml off


Create Index idxFKProduto on tItemMovimento (iidproduto,iidMovimento) with (drop_existing = on)
go

set statistics io on 
set statistics xml on

select * from tItemMovimento 
where iIDProduto = 2570
  and iIDMovimento = 45361

select * from tItemMovimento 
where iIDProduto = 80491
  and iIDMovimento = 97088

set statistics io off
set statistics xml off