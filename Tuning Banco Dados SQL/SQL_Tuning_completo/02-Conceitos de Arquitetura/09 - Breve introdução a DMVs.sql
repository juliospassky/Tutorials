/*
DMV ou Exibições de Gerenciamento Dinâmico 

- As DMVs são objetos que informam o estado de diversos componentes de 
  uma instância do SQL Server, retornando um conjunto de informações
  úteis que irão nós ajudar por exemplo em entender o armazenamento ou a 
  utilização de recursos. Claro, ajudar a identificar as querys mais lentas.

- Elas são acessas pela instrução SELECT e podem fazer parte de JOIN com outras
  DMVs. Apesar do nome ser exibição, as DMVs podem ser views ou functions.

- As informações apresentados podem ser dados armazenados ou capturados do ambiente
  da instância, sistema operacional ou banco de dados.

- Elas são divididas em grupos.

- São do eschema SYS e, na grande maioria dos casos, começam do o prefixo DM.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views

Obs: Alguns momento iremos apresentar exibições do sistema que não são classificadas como DMVs. 

*/


use DBDemo
go

Select name,type, type_desc  
  From sys.system_objects
 Where name like 'DM[_]%'
 Order by name
go

Create or Alter View vDMVs
as
Select substring(substring(name,4,100),1,charindex('_',substring(name,4,100))-1)  as tipo,  
       name,
       type, 
       type_desc  
  From sys.system_objects
 Where name like 'DM[_]%'

go


/*
DMVs de Sistema Operacional do SQL Server - OSSQL.
--------------------------------------------------
*/

select * from vDMVs where tipo = 'os'

select * from sys.dm_os_host_info
select * from sys.dm_os_sys_info

select * from sys.dm_os_sys_memory

select * from sys.dm_os_file_exists('c:\windows\system.ini')
select * from sys.dm_os_file_exists('c:\windows')


-- Apresenta os contadores de desempenho para o SQL Server 
select * from sys.dm_os_performance_counters


-- Apresenta todos os buffer pools onde as paginas estão localizadas
select * from sys.dm_os_buffer_descriptors

-- Apresenta o tamanho ocupado atual do buffer pool 
select count(*) * 8 / 1024.0  as nTamanhoBufferMB from sys.dm_os_buffer_descriptors

-- Apresenta o tamanho ocupado atual do buffer pool para cada banco de dados
select db_name(database_id) as cDatabase , 
       count(*) * 8 / 1024.0  as nTamanhoBufferMB 
  from sys.dm_os_buffer_descriptors
 group by db_name(database_id)
 order by nTamanhoBufferMB desc 




/*
DMVs relacionadas as execuções, conexões e sessão.
--------------------------------------------------
*/

Select * From vDMVs Where tipo = 'exec'


/*
Mostra as Sessões autenticadas na instância do SQL Server.
*/

Select * 
  From sys.dm_exec_sessions

/*
Session_id até 50 são sessões utilizadas internamente pelo SQL Server 
*/

Select * 
  From sys.dm_exec_sessions 
  Where session_id >= 51

/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sessions-transact-sql?view=sql-server-2017
*/

/*
Mostra as informações sobre as execuções
*/

Select * 
  From sys.dm_exec_requests 
  Where session_id >= 51
  
Select @@SPID  -- Retorna a Identificação da sessão do processo da conexão atual 

Select * 
  From sys.dm_exec_requests 
  Where session_id = @@SPID

/*
Atenção!!!
Somente abrar o arquivo 09a - Apoio a Introdução a DMVs.SQL
Será estabelecida uma nova sessão.

*/

Select session_id ,  program_name, login_name , status, cpu_time, memory_usage, 
       reads, writes, logical_reads 
  From sys.dm_exec_sessions 
  where session_id >= 51 

Select session_id, start_time , status, command  , database_id , cpu_time , 
       reads, writes, logical_reads ,sql_handle
  From sys.dm_exec_requests 
  Where session_id >= 51


/*
Visualiza o conteúdo do SQL_HANDLE 
*/

select text from sys.dm_exec_sql_text(0x020000007316630B97894DB33C1DEFD265921F0E7CA47E120000000000000000000000000000000000000000)


/*
Estatísticas de desempenho dos planos de execução.
*/

select * from sys.dm_exec_query_stats

/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?view=sql-server-2017
*/


/*
DMVs relacionadas a banco de dados 
----------------------------------
*/

select * from vDMVs where tipo = 'db'
order by name 



use DBDemo
go

select * from sys.dm_db_file_space_usage




use DBDemoTable
go
select * from sys.dm_db_file_space_usage

/*
DMVs relacionadas a índices 
----------------------------
*/

use DBDemo
go


/*
Apresenta os indices atuais, utilizando as views de catálogo do sistema.

Abrir o arquivo 09a - Apoio a introdução a DMVs
ir até "Segunda parte - Para explicação das DMVs relacionadas a índices"
e executar o script 01 e 02 .

*/


Select * from sys.indexes 
Select * from sys.tables


Select tab.name as cTable , ind.name as cIndex    , ind.type_desc as cTypeIndex  , ind.index_id 
  From sys.indexes ind 
  Join sys.tables tab
   on ind.object_id = tab.object_id 
  where tab.name = 'tCliente'
  order by index_id


/*
Identificando as tabelas, seus indices e colunas dos índices (chaves) 
*/
 
Select tab.name as cTable , 
       ind.name as cIndex , 
       ind.type_desc  as cTypeDesc , 
       indcol.key_ordinal as nOrdinal  , 
       col.name as cColumn
  from sys.tables as tab
  join sys.indexes as ind 
   on tab.object_id = ind.object_id 
  join sys.index_columns indcol 
    on ind.index_id = indcol.index_id and ind.object_id = indcol.object_id 
  join sys.columns as col
    on indcol.column_id = col.column_id and indcol.object_id =  col.object_id 
  where tab.name = 'tCliente'
    order by ind.index_id, indcol.key_ordinal

sp_helpindex tCliente

/*

*/


Select * From sys.dm_db_index_usage_stats
where database_id = DB_ID()

-- Apresenta o tamanho e fragmentação dos dados e índices.
Select   * From sys.dm_db_index_physical_stats(db_id(),null,null,null,'LIMITED')

-- Apresenta as operações de leitura e gravação do nível mais baixo.
Select * from sys.dm_db_index_operational_stats(db_id(),null,null,null)



