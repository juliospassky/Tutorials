use eCommerce
go

select * from sys.indexes 


select * from sys.dm_db_index_usage_stats

/*

*/
select * from sys.dm_db_missing_index_group_stats
select * from sys.dm_db_missing_index_groups
select * from sys.dm_db_missing_index_details


Select tab.name as cTable , 
       ind.name as cIndex,  
       iu.user_seeks,
       iu.user_scans,
       iu.user_lookups,
       iu.user_updates,
       iu.last_user_seek,
       iu.last_user_scan,
       iu.last_user_lookup,
       iu.last_user_update 
  From sys.dm_db_index_usage_stats iu
  Join sys.tables tab
    on iu.object_id = tab.object_id 
  join sys.indexes as ind 
    on tab.object_id = ind.object_id and iu.index_id = ind.index_id
 where database_id = DB_ID()
   order by iu.object_id,iu.index_id


/*
Sugestão de índices ausentes.
*/
select top 20
	    round(s.avg_total_user_cost *
		       s.avg_user_impact
		       * (s.user_seeks + s.user_scans),0
             ) as [Total Cost],
       d.[statement] AS [Table Name]	, 
       equality_columns	, 
       inequality_columns	, 
       included_columns
  from sys.dm_db_missing_index_groups g
  join sys.dm_db_missing_index_group_stats s
	 on s.group_handle = g.index_group_handle
  join sys.dm_db_missing_index_details d
	 on d.index_handle = g.index_handle
order by [Total Cost] desc

/*
Indices não utilizados
*/
select * from sys.indexes 
select * from sys.tables

  select o.name as cTabela , 
         i.name as cIndex ,
         s.user_updates 
  from sys.indexes i 
  left join sys.dm_db_index_usage_stats s
    on s.object_id = i.object_id
	and s.index_id = i.index_id
  join sys.tables o 
    on i.object_id = O.object_id
 where o.is_ms_shipped = 0
	and (isnull(s.user_seeks,0) + isnull(s.user_scans,0) + isnull(s.user_lookups,0)) = 0
   and i.name is not null
 order by s.user_updates desc



/*
Índices com alta Manutenção
*/

SELECT TOP 20
       SCHEMA_NAME(o.Schema_ID) AS SchemaName	, 
       OBJECT_NAME(s.[object_id]) AS TableName	, 
       i.name AS IndexName	, 
       s.user_updates AS [update usage]	, 
       (s.user_seeks + s.user_scans + s.user_lookups)
								AS [Retrieval usage]	, 
       (s.user_updates) -	(s.user_seeks + user_scans +	s.user_lookups) AS [Maintenance cost]	, 
       s.system_seeks + s.system_scans + s.system_lookups AS [System usage]	, 
       s.last_user_seek	, 
       s.last_user_scan	, 
       s.last_user_lookup
  from sys.dm_db_index_usage_stats s
  join sys.indexes i 
    on s.[object_id] = i.[object_id]
	and s.index_id = i.index_id
  join sys.objects o 
    on i.object_id = O.object_id
 where s.database_id = DB_ID()
	and i.name is not null
	AND o.is_ms_shipped = 0
	AND (s.user_seeks + s.user_scans + s.user_lookups) > 0
order by [Maintenance cost] desc

/*
Índices mais utilizados. 
*/

select top 20
	    schema_name(o.Schema_ID) AS SchemaName	, 
       object_name(s.[object_id]) AS TableName	, 
       i.name AS IndexName	, 
       (s.user_seeks + s.user_scans + s.user_lookups) AS [Usage]	, 
       s.user_updates	, 
       i.fill_factor
  from sys.dm_db_index_usage_stats s
  join sys.indexes i ON s.[object_id] = i.[object_id]
	and s.index_id = i.index_id
  join sys.objects o ON i.object_id = O.object_id
 where s.database_id = DB_ID()
	and i.name IS NOT NULL
	and o.is_ms_shipped  = 0
 order by [Usage] desc

















/*
Apresenta os indices atuais, utilizando as views de catálogo do sistema.

Abrir o arquivo 09a - Apoio a introdução a DMVs
ir até "Segunda parte - Para explicação das DMVs relacionadas a índices"
e executar o script 01, 02 e 03 juntos .

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

/*

*/


Select * From sys.dm_db_index_usage_stats
where database_id = DB_ID()


/*
Estatísticas de utilização de índices
*/

use DBDemo
go

Select tab.name as cTable , 
       ind.name as cIndex,  
       iu.user_seeks,
       iu.user_scans,
       iu.user_lookups,
       iu.user_updates,
       iu.last_user_seek,
       iu.last_user_scan,
       iu.last_user_lookup,
       iu.last_user_update 
  From sys.dm_db_index_usage_stats iu
  Join sys.tables tab
    on iu.object_id = tab.object_id 
  join sys.indexes as ind 
    on tab.object_id = ind.object_id and iu.index_id = ind.index_id
 where database_id = DB_ID()
   order by iu.object_id,iu.index_id