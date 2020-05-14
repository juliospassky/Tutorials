/*
Colunas incluídas e índice de cobertura.

- Colunas incluídas em um índice, é um recurso que permite incluír colunas na definição do
  índice e que não farão parte da chave.

- Índice é uma estrutura b-tree, onde as colunas chaves são distribuídas a partir do nó raiz,
  para as nós intermediários e por fins chegando aos nós folhas. No SQL Server, os nós são
  as páginas de índices.

- Essas colunas serão incluída no índice, mas ficarão apenas nas páginas folhas. Como elas ficam
  nas páginas folhas, somente índices não clusterizado podem utilizar esse recurso.

- Colunas incluídas no índices não são utilizadas como chave de pesquisa. Esse recurso
  existe para evitar o Key Lookup ou RID Lookup

Sintaxe: 
Create NonClustered Index <Nome do Indice> 
                       on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 
					   Include ((<Coluna3>,<Coluna4>,...) 


- Índice de Cobertura é um conceito de índice que contém na chave todas as colunas que atende 
  a query. Todas as colunas que estão no índice "cobre" todas as colunas da query. 
  Para evitar de sobrecarregar as chaves do índice, usamos a  opção INCLUDE 

- A consulta carrega todos os dados que necessita apenas pesquisando no índice, sem a necessidade de acessar
  a tabela. 
  

Exemplo

*/

/*
Montar uma pesquisa que mostre somente os produtos de um determiando pedido 
que a multiplicação da quantidade do produto pelo seu preço for maior que 
um valor informado. Apresentar o ID do produto, os valores separados e o valor
calculado.
*/

use eCommerce
go

sp_helpindex tItemMovimento
go

drop index if exists idxMovimento  on tItemMovimento
drop index if exists idxFKProduto on tItemMovimento
go

set statistics io  on 

Select iIDItem, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
  

/*
Table 'tItemMovimento'. Scan count 3, logical reads 17287, physical reads 0, read-ahead reads 17180, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

/*
Alocação dos dados 
*/ 
select object_name(p.object_id) as cTabela,
       rows,
       total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc ,
	   p.index_id ,
	   i.name ,
	   i.type_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
  join sys.indexes i 
    on p.index_id = i.index_id 
   and p.object_id = i.object_id
 where p.object_id in ( object_id('tItemMovimento') )
go

/*

cTabela	      rows	   total_pages		used_pages	data_pages	data_compression_desc	index_id	name			      type_desc
tItemMovimento	2611043	17219	         17211	      17179	      NONE	                  1	      PKItemMovimento	CLUSTERED
*/

Create Index IDXMovimento 
    on tItemMovimento (iIDMovimento, nQuantidade, mPreco) 
go

Select iIDItem, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
go

/*
Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.


cTabela	      rows	   total_pages		used_pages	data_pages	data_compression_desc	index_id	name			      type_desc
tItemMovimento	2611043	17219	         17211	      17179	      NONE	                  1	      PKItemMovimento	CLUSTERED
tItemMovimento	2611043	8443	         8431	      8396	      NONE	                  4	      IDXMovimento	   NONCLUSTERED
tItemMovimento	2611043	8443	         8418	      8396	      NONE	                  4	      IDXMovimento	   NONCLUSTERED
*/

sp_helpindex tItemMovimento


/*
Algumas percepções :

- A coluna iidMovimento não é exclusiva na tabela e também possue uma SELETIVIDADE alta. Isso significa
  que os dados dessas coluna possuem baixa redundância  e quando fazemos uma pesquisa
  por essa coluna, ela é bem seletiva, retornando poucas linhas.

- Índice é utilizado para aumentar a performance da query. Então na chave do índice somente coloque colunas
  que serão utilizada para realizar buscas e pesquisas. Assim elas tendem a ser tornar pequenas e eficientes.

*/

/*
Vamos usar então a opção INCLUDE e colocar as colunas nQuantidade, mPreco
*/


Create Index IDXMovimento 
     on tItemMovimento (iIDMovimento) 
include (nQuantidade, mPreco) 
   with (drop_existing=on)

go

Select iIDItem, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
go

/*
Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/




/*
Para termos um indice de cobertura, temos que ter todas as colunas da query dentro do índice.

*/

Select iIDItem, iidProduto, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
go


 Create Index IDXMovimento 
     on tItemMovimento (iIDMovimento) 
include (nQuantidade, mPreco, iidProduto) 
  with (drop_existing=on)

go


/*
Como sei que um indice tem colunas incluídas? 
*/

set statistics io off


sp_helpindex 'tItemMovimento'

---
select i.name  ,
		i.index_id , 
		c.name  , 
		is_descending_key  , 
		is_included_column , 
		key_ordinal
from sys.index_columns ic 
join sys.columns c 
	on ic.object_id = c.object_id and  ic.column_id = c.column_id
join sys.indexes i  on ic.object_id = i.object_id and  ic.index_id = i.index_id
where ic.object_id = object_id('tItemMovimento')
  and i.name  ='IDXMovimento'

/*
Ou utiliza a power procedure sp_helpindex2 
*/



sp_helpindex2 'tItemMovimento'
go

sp_helpindex2 'tItemMovimento' , @nOptions = 1
go

sp_helpindex2 'tItemMovimento' , @nOptions = 2
go

sp_helpindex2 'tItemMovimento' , 'IDXMovimento', @nOptions = 3
go

