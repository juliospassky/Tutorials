/*
O que são os Extents ou Extensões 
-------------------------------------

Extent ou Extensão são agrupamentos de 8 páginas de dados
fisicamente contíguas.

Um Extent tem o tamanho de 64Kb.

O objetivo é gerenciar melhor o armazenamento físico dos dados.

*/

use DBDemo
go

drop table if exists TesteExtendA
go

drop table if exists TesteExtendB
go

Create Table TesteExtendA (
  Titulo char(8000)
)

go
Create Table TesteExtendB (
  Titulo char(8000)
)
go

insert into TesteExtendA values (replicate('A', 8000))
insert into TesteExtendB values (replicate('B', 8000))
GO 32 -- Replete os comandos em lote 32 vezes 

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from TesteExtendA as tab
 
select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from TesteExtendB as tab

  /*
 -- Utilizando a DMV  sys.dm_db_database_page_allocations
 Uma DMV não documentada.
 Ela tem 5 parâmetros.

 DB_ID				- ID do banco de dados. Vc pode obter esse id usando a função DB_ID()
 OBJECT_ID			- ID do objeto de alocação de dados. Utiliza a função OBJECT_ID() para obter o ID.
 INDEX_ID			- ID do índice. Vamos assumir NULL.
 PARTITION_NUMBER	- Número da partição da tabela. Vamos assumir NULL.
 MODO             - LIMITED OU DETAILED 

 Ref.: https://www.dbbest.com/blog/looking-inside-database-pages/
 */


select extent_page_id as extent  , 
       allocated_page_page_id as page, 
       is_mixed_page_allocation
  from sys.dm_db_database_page_allocations(db_id(),object_id('TesteExtendA'),null,null,'DETAILED')
 order by page

select extent_page_id as extent  , 
       allocated_page_page_id as page, 
       is_mixed_page_allocation
  from sys.dm_db_database_page_allocations(db_id(),object_id('TesteExtendB'),null,null,'DETAILED')
 order by page


 select object_name(object_id) as cTabela, 
        allocated_page_page_id as pageid 
   from sys.dm_db_database_page_allocations(db_id(),null,null,null,'DETAILED')
  where extent_page_id = 448
  order by pageid 
  


