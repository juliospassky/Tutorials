/*
Como Monitorar o 
*/

/*
Criar uma Extended Events para capturar eventos de Pages Splits
*/

drop EVENT SESSION xePageSplits ON SERVER 
go

CREATE EVENT SESSION xePageSplits ON SERVER 
   ADD EVENT sqlserver.page_split(
    ACTION(sqlserver.session_id,
           sqlserver.sql_text,
           sqlserver.transaction_id,
           sqlserver.transaction_sequence,
           sqlserver.database_name )
   )
   ADD TARGET package0.event_file 
   (
      SET filename=N'C:\XE\xePageSplits.xel'
   )
GO

/*
Rotina para ler o conteudo do arquivo.
*/


/*
<event name="page_split" package="sqlserver" timestamp="2018-06-21T18:26:33.120Z">
  <data name="file_id">
    <value>4</value>
  </data>
  <data name="page_id">
    <value>24537</value>
  </data>
  <data name="database_id">
    <value>10</value>
  </data>
  <data name="rowset_id">
    <value>72057594049789952</value>
  </data>
  <data name="splitOperation">
    <value>0</value>
    <text>SPLIT_FOR_INSERT</text>
  </data>
  <data name="new_page_file_id">
    <value>4</value>
  </data>
  <data name="new_page_page_id">
    <value>64</value>
  </data>
</event>
*/

;
With cteDados as (
   Select OBJECT_NAME AS cEvent, 
          CONVERT(XML, event_data) AS xData,
	       cast(SWITCHOFFSET(timestamp_utc ,'-03:00') as datetime) as dDateTime
     FROM sys.fn_xe_file_target_read_file('C:\XE\xePageSplits*.xel',null,null,null)
)
Select cEvent, 
       xData,
	    dDateTime as dDataHora,
       xData.value('(/event/data[@name=''file_id'']/value)[1]','int')             as nFileID ,
       xData.value('(/event/data[@name=''page_id'']/value)[1]','int')            as nPageID,
       xData.value('(/event/data[@name=''database_id'']/value)[1]','int')       as nDataBaseID,
       xData.value('(/event/data[@name=''rowset_id'']/value)[1]','bigint')      as nRowSetID,
       xData.value('(/event/data[@name=''splitOperation'']/text)[1]','varchar(max)')              as cSplitOperation,
       xData.value('(/event/data[@name=''new_page_file_id'']/value)[1]','int')           as nNewPageFileID,
       xData.value('(/event/data[@name=''new_page_page_id'']/value)[1]','int')  as nNewPageID
  FROM cteDados
 Order by dDataHora

/*
Criar dois cenários onde um ocorre uma inserção de dados no meio do índice e outro
onde ocorre inserções no final do índice.

*/
use eCommerce
go

sp_helpindex2 tItemMovimento

/*
PKItemMovimento	Clustered, Unique, Primary Key	[iIDItem],	               NULL
IDXMovimento	   Nonclustered	                  [iIDMovimento],[mValor],	[nQuantidade],[mPreco],[iIDProduto],
idxFKProduto	   Nonclustered	                  [iIDProduto],	            NULL
*/

SELECT TOP 10 * FROM tItemMovimento

Alter Event Session xePageSplits
   on Server
State = start
go


Insert into tItemMovimento  (iIDMovimento,iIDProduto, nQuantidade, mPreco , mDesconto , mICMS, nQtdEmbalagem)
select top 1 iIDMovimento, 
       (select top 1 iidproduto from tproduto order by newid()) as iidProduto, 
       rand()*100,
       rand()*100,
       0,
       0,
       0
       from tMovimento 
       order by newid()
go 100

Alter Event Session xePageSplits
   on Server
State = stop 
go

/*
*/


Select *  From sys.dm_xe_packages pack

select distinct object_type from sys.dm_xe_objects


select * from sys.dm_xe_objects
where name like'page_split%'

select * from sys.dm_xe_object_columns
where object_name like 'page_split%'


Select pack.name as cPackage ,
       pack.description,
       obj.name as cEvent, 
       obj.object_type as cType,
       obj.description cDescriptionEvent ,
       map.*
  From sys.dm_xe_packages pack
  join sys.dm_xe_objects obj 
    on pack.guid = obj.package_guid
  left join sys.dm_xe_map_values map
    on obj.package_guid = map.object_package_guid 
   and obj.name = case when map.name = 'log_op' then 'Transaction_log' else map.name end 
 where (obj.name like 'page_split%' or obj.name like 'transaction_log%')
 order by cEvent 


 select * from sys.dm_xe_map_values 
 where name = 'log_op'


Select obj.* 
--       map.* 
  From sys.dm_xe_objects obj 
  left join sys.dm_xe_map_values map 
    on obj.package_guid = map.object_package_guid
   and obj.name = case when map.name = 'log_op' then 'Transaction_log' else map.name end 
where (obj.name like 'page_split%' or obj.name like 'Transaction_log%')

 
 select object_package_guid , name , *  from sys.dm_xe_map_values 
 where map_value LIKE '%SPLIT%'




Select object_name(ios.object_id) as cTable , 
       i.name as cIndex,
       leaf_allocation_count ,  
       nonleaf_allocation_count
from sys.dm_db_index_operational_stats(db_id(),NULL,NULL,NULL) ios 
join sys.indexes i 
  on ios.object_id = i.object_id and ios.index_id = i.index_id
where object_name(ios.object_id) = 'tDemoPageSplit'




/*
--------------------------------------------
*/
use DBDemo
go

drop table if exists tClienteDemo1
go
drop table if exists tClienteDemo2
go


/*
Criando uma tabela para simular page split 
no meio da página 
*/

Create Table tClienteDemo1 (
   nCPF numeric(11) ,
   cNome varchar(100), 
   dCadastro datetime default getdate()
   Constraint PKClienteDemo1 Primary key 
   (
      nCPF
   )
)
go
--Create Index idxCadastro on tClienteDemo1 (dCadastro) 
go



/*
Criando uma tabela para simular page split 
no final da Página 
*/

Create Table tClienteDemo2 (
   iIDCliente int not null identity(1,1) ,
   cNome varchar(100), 
   nCPF numeric(11),
   dCadastro datetime default dateadd(mi, rand()*-1000,getdate())
   Constraint PKClienteDemo2 Primary key 
   (
      iIDCliente
   )
)
go
--Create Index idxCadastro on tClienteDemo2 (dCadastro) 


sp_helpindex2 'tClienteDemo1'
go
sp_helpindex2 'tClienteDemo2'
go


/*
*/

set nocount on 
go

truncate table tClienteDemo1
truncate table tClienteDemo2
go

Declare @nCont int = 1
Declare @nCPF numeric(11) = cast(rand()*99999999999 as numeric(11))

while @nCont <= 199519 begin 
   
   while exists (select top 1 1 from tClienteDemo1 where nCPF = @nCPF)
      set @nCPF = cast(rand()*99999999999 as numeric(11))
  
   Insert into tClienteDemo1 (nCPF, cNome) 
   select @nCPF, cNome from eCommerce.dbo.tCliente where iIDCliente = @nCont 
   
   Insert into tClienteDemo2 (nCPF, cNome) 
   select cast(cCPF as numeric(11)), cNome from eCommerce.dbo.tCliente where iIDCliente = @nCont 
       
   set @nCont += 1

end 

select count(1) from tClienteDemo1
select count(1) from tClienteDemo2

/*
*/


Alter Event Session xePageSplits
   on Server
State = start
go

   Insert into tClienteDemo1 (nCPF, cNome) 
   select top 1 cast(rand()*99999999999 as numeric(11)), cNome from eCommerce.dbo.tCliente order by newid() 
go 100   
   Insert into tClienteDemo2 (nCPF, cNome) 
   select top 1 cast(cCPF as numeric(11)), cNome from eCommerce.dbo.tCliente order by newid()
go 100

Alter Event Session xePageSplits
   on Server
State = stop 
go




/*
*/



use DBDemo
go

drop table if exists tDemoPageSplit 
go

Create Table tDemoPageSplit (id numeric(11), cNome char(800)) 
go

Create Clustered Index idcDemo on tDemoPageSplit (cNome, id)
go

insert into tDemoPageSplit (cNome, id )
values ('APARECIDA' ,34534534),('BRUNO',344345345),('CAROLINA',3453453453),
       ('DANIEL',4353434),('FABIO',34545343),
       ('GUSTAVO',4556456),('HELOI',434534534),('IVAN',45456546),('JOAQUIM',3453454),
       ('KATIA',34534534)
go
Select *   From tDemoPageSplit 
go

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as RID , * 
  From tDemoPageSplit 
go

/*
(1:4940:0)	34534534	APARECIDA                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
(1:4940:1)	344345345	BRUNO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
(1:4940:2)	3453453453	CAROLINA                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
(1:4940:3)	4353434	DANIEL                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
(1:4940:4)	34545343	FABIO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
(1:4940:5)	4556456	GUSTAVO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
(1:4940:6)	434534534	HELOI                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
(1:4940:7)	45456546	IVAN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
(1:4940:8)	3453454	JOAQUIM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
(1:4943:0)	34534534	KATIA                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
*/
Alter Event Session xePageSplits
   on Server
State = start
go

Insert into tDemoPageSplit (cNome, id )
Values ('ELOISA' ,3454534)
go

Alter Event Session xePageSplits
   on Server
State = stop 
go

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as RID , * 
  From tDemoPageSplit 
go
