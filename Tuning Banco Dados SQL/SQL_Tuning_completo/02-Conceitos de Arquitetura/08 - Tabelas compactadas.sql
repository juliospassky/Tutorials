/*

Compactação de dados. 

-- Recurso do SQL Server para compactar dados pelas linhas ou páginas de dados.

-- A compactação tem como objetivo reduzir o espaço alocado pelo banco de dados em 
   disco, como também aumentar a performance de acesso aos dados, visto que com a 
   compactação, é possível alocar mais bytes em uma página de dados.

-- Ela não altera o tamanho da página de dados como também não
   altera o limite de bytes em um linha de dados, que é de 8060 bytes, mas
   permite alocar um maior número de linhas por páginas.
   
-- Pode ser aplicada em uma tabela sem índices (heap table),
   uma tabela com índices agrupado (clusterizado) ou apenas compactação de 
   índices.

-- Mas não é toda da tabela que pode ser compactada ou que realmente teremos
   algum ganho de armazenamento ou performance se compactaramos.

-- Um exemplo é uma tabela cuja a soma dos bytes armazenados for próximo a 8060 caracteres,
   não haverá ganho de compactação significativo devido ao total de bytes que serão
   compactados mais os bytes adicionais para realizar a compactação.

-- Uma tabela quem contém muitos dados exclusivos (ou únicos) não ganhará benefícios
   da compactação.

-- Vamos fazer a compactação com 3 cenários e utilizando a compactação de páginas.

Ref.: https://msdn.microsoft.com/en-us/library/dd894051.aspx


*/

use DBDemo
go


/*
Cadastro de clientes 
Tamanho da linha : 500 bytes
Dados : Tabela de cadastro com alto índices de dados exclusivos.

*/

drop table if exists tCliente

select iIDCliente, iIDEstado, cNome, cCPF, cEmail, cCelular, dCadastro, dNascimento, cLogradouro, cCidade, cUF, cCEP, dDesativacao, mCredito
  into tCliente 
  From eCommerce.dbo.tCliente

select top 10 *  from tCliente
go

sp_spaceused 'tCliente'

sp_help 'tCliente'

EXEC sp_estimate_data_compression_savings 'dbo', 'tCliente', null, NULL, 'PAGE' ;  
go

-- Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-estimate-data-compression-savings-transact-sql

/*
Tamanho atual    = 32.136 KB
Tamanho estimado = 30.064 KB
Taxa estimada    =    6,54%

*/

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('tCliente')
	  and au.type = 1
go

/*
total_pages          used_pages           data_pages           data_compression_desc
-------------------- -------------------- -------------------- ------------------------------------------------------------
4025                 4017                 4016                 NONE
*/

ALTER TABLE dbo.tCliente
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('tCliente')
	  and au.type = 1

/*
         total_pages          used_pages           data_pages           data_compression_desc
         -------------------- -------------------- -------------------- ------------------------------------------------------------
Antes    4025                 4017                 4016                 NONE
Depois   3769                 3757                 3756                 PAGE

*/


/*
Movimento 
Tamanho da linha : 120 bytes
Dados : Tabela de movimentos, com dados de tamanho curto, com tendências de dados repetidos e colunas com NULL.

*/
drop table if exists tMovimento
go

select * into tMovimento from eCommerce.dbo.tMovimento 
go

sp_spaceused 'tMovimento'   
sp_help 'tMovimento'
go

EXEC sp_estimate_data_compression_savings 'dbo', 'tMovimento', null, NULL, 'PAGE' ;  
go

/*
Tamanho atual    = 17.464
Tamanho estimado =  5.984
Taxa estimada    =    66%

*/

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tMovimento')
	
go
/*
total_pages          used_pages           data_pages           data_compression_desc
-------------------- -------------------- -------------------- ------------------------------------------------------------
1977                 1962                 1961                 NONE

*/

ALTER TABLE dbo.tMovimento 
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tMovimento')
	 
/*
         total_pages          used_pages           data_pages           data_compression_desc
         -------------------- -------------------- -------------------- ------------------------------------------------------------
Antes    1977                 1962                 1961                 NONE
Depois    673                  666                  665                 PAGE
       65.95%
           
*/


/*
Movimento de Itens 
Tamanho da linha : 50 bytes
Dados : Tabela dos itens do movimento, com dados de tamanho curto e somente númericos e com tendências de dados repetidos.


*/
drop table if exists tItemMovimento
go

select * into tItemMovimento from eCommerce.dbo.tItemMovimento
go

select top 10 * from tItemMovimento
go


sp_spaceused 'tItemMovimento'
sp_help 'tItemMovimento'


EXEC sp_estimate_data_compression_savings 'dbo', 'tItemMovimento', null, NULL, 'PAGE' ;  
go

/*
Tamanho atual    = 29.640
Tamanho estimado = 10.168
Taxa estimada    = 65,69%

*/

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tItemMovimento')
	
go
/*
total_pages          used_pages           data_pages           data_compression_desc
-------------------- -------------------- -------------------- ------------------------------------------------------------
3305                 3293                 3292                 NONE

*/

ALTER TABLE dbo.tItemMovimento 
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go

select total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
 where p.object_id = object_id('tItemMovimento')
	 
/*
/*
         total_pages          used_pages           data_pages           data_compression_desc
         -------------------- -------------------- -------------------- ------------------------------------------------------------
Antes    3305                 3294                 3293                 NONE
Depois   1137                 1124                 1123                 PAGE
       65,59%
*/
           





