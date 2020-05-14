use eCommerce
go

declare @cmd varchar(max) = ''
select @cmd  = @cmd  + 'drop index '+tab.name+'.'+ind.name +'
'
 From sys.indexes ind 
 join sys.tables tab
 on ind.object_id = tab.object_id 
 where index_id > 0
   and tab.name not in ('TRegiao','tEstado')

execute (@cmd )

go





use master
go


/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Stored Procedure        
Objeto     : sp_HelpIndex2 
Objetivo   : 
Projeto    : Administração de banco de Dados         
Empresa Responsável: ForceDB
Criado em  : 27/11/2014
Execução: SSMS        
Palavras-chave: Indices, Tabelas, Tamanho, Utilização  
----------------------------------------------------------------------------------------------        
Dicionário:        
Executar sp_ms_marksystemobject 'sp_HelpIndex2'

-- IDBUG [00000]
----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Wolney M. Maia               27/11/2014 Criação da Procedure 
Wolney M. Maia               19/02/2015 Quando informado o parametro @nOptions = 2, separar a apresentação dos user_seeks ,user_scans , user_lookups
Wolney M. Maia               19/02/2015 Informar o tamanho da tabela em MBytes, junto com o tamanho em Paginas de Dados
Wolney M. Maia               05/03/2015 Inclusão da coluna cRecommendationIndex. Com base na fragmentação, essa coluna tem os valores Reorganize ou Rebuild. 
Wolney M. Maia               09/03/2015 No cabeçalho da procedure, foi incluido a coluna IDbug no Historico, para referencia dentro do codigo, para identificar a correção.
Wolney M. Maia         00001 09/03/2015 Inclusão da instrução "collate SQL_Latin1_General_CP1_CI_AI"
Wolney M. Maia         00002 12/03/2015 Inclusão da função ISNULL para as coluna user_updates , user_seeks, user_scans, user_lookups, user_updates
Wolney M. Maia         00003 17/03/2015 Inclusao da coluna Fill Factor 
Wolney M. Maia         00004 18/03/2015 Inclusão do calculo da Ranking para as estatisticas das colunas user_updates , user_seeks, user_scans, user_lookups, user_updates
Wolney M. Maia         00005 18/03/2015 Inclusao da instrucao set transaction isolation level read uncommitted ;
Wolney M. Maia         00006 18/03/2015 Filtrando objetos o.type not in ('S','IT','TF') para não serem processados 
Wolney M. Maia         00007 31/03/2015 Inclusão da coluna para mostrar a data em que a estatistica para o indice foi atualizada. 
Wolney M. Maia         00008 04/08/2015 Quando uma tabela é Heap e tem um indices não cluster, somente era apresentado a linha com a Headp. 
Wolney M. Maia         00009 12/09/2015 Inclusao da coluna DISABLE para indicar se um indice está desativado ou nãp 
Wolney M. Maia         00010 07/12/2015 Inclusao da coluna index_id na apresentação. Inclusão de Order By no select de apresentação .
                                        Coleta de dados de Pages, Size e rows da CTE de Indices ou da CTE de Indices Avançado.
Wolney M. Maia         00011 09/06/2017 Inclusão da instrução SET ANSI_WARNINGS OFF para não mostrar os avisos de descarte de dados null
                                        durante a agregação de dados. 
Wolney M. Maia         00012 09/06/2017 Inclusão da coluna nPartitionNumber. 
Wolney M. Maia         00013 09/06/2017 Inclusão do teste de perfil de sysadmin para permiti apresentado em detalhes do indices 
Wolney M. Maia         00014 09/09/2017 Inclusão do schema na composição do nome da tabela 
Wolney M. Maia         00015 12/06/2017 Inclusão do parametro 2 do help para mostrar o número da versão da procedure.
*/
use master
go
Create or Alter Procedure dbo.sp_HelpIndex2
@cTableName sysname = null ,
@cIndexName sysname = null, 
@nOptions int = 0 , -- 0 (2)  is Default (Retorna dados do indice)
                     -- 1 (4)  is Usage (Retorna os dados de utilizacao do Indices)
					 -- 2 (8)  is Statistics Limited (Retorna os dados de Estatisticas do Indices)
					 -- 3 (16) is Statistics Advanced (Retorna os dados de Estatisticas do Indices)
					 
@cResultTable sysname = null  ,    -- Nome da tabela que receberá os dados. Ela será criada no banco de dados do contexto da execução 

@nOptionsResultTable tinyint = 2 , -- 2 - Incluir Dados
                                   -- 4 - Apagar Dados 
                                   -- 8 - Apresentar Dados 
                                   -- 16 - Drop a tabela 
@nHelp tinyint = 0   -- 0 Não mostra nada
                     -- 1 Mostra o Help da instrução sp_helpindex2 
					 -- 2 Mostra o numero da versão da procedure.
as
begin 

   -- IDBUG [00005]
   set transaction isolation level read uncommitted ;
   
   -- IDBUG [00011]
   declare @nValorAnsiWarnigns int 
   set @nValorAnsiWarnigns = @@OPTIONS & 8 
       
   set ansi_warnings off 
      
   /*
   if @nHelp = 1 begin 
       execute sp_HelpObjects 'sp_HelpIndex2'
	   return 
   end 
   */
   if @nHelp = 2 begin 
       select 'Versão 1.14'
	   return 1.14
   end 

   set nocount on ;
   
   declare @cCommand nvarchar(max) 

   Declare @cParseName sysname 
   Declare @cObjectInvalid sysname 
   Declare @nIndexID int 
   
   Declare @cSchemaSyscolumns sysname 
   
   Declare @cMode sysname = 'Limited'
   
   Declare @dStartSQLServer datetime 
   
   Select @dStartSQLServer = sqlserver_start_time from sys.dm_os_sys_info

   if @nOptions = 3 
	  set @cMode =  'Detailed' ;
   
   if @cResultTable is null
      set @nOptionsResultTable = 8
   
   if @cTableName is null
      set @cIndexName = null
   
   
   /*
   Criar a tabela temporaria para receber o resultado da execução
   */
    
   Create Table #tTMPFdBHelpIndex(
		        cDatabaseName varchar(128) NULL,
		        cTableName sysname NOT NULL,
		        cName sysname NULL,
		        iIndexID int , -- IDBUG [00010]
		        cDescription varchar(210) NULL,
		        cKeyColumns varchar(max) NULL,
		        cIncludeColumns varchar(max) NULL,
		        cFilterDefinition varchar(max) NULL,
		        lDisable bit not null default 0,
		        nFillFactor int null ,
		        cFileGroup sysname NOT NULL,
		        dStatsUpdate datetime null,
		        cAllocationType varchar(60) NULL,
		        nPartitionNumber int NULL,  ---- IDBUG [00012]
		        cCompression varchar(20) NULL,
		        nDataPages bigint NULL,
				nSizeInMB float NULL,
		        nRows bigint NULL,
			    nUserUsage bigint NULL, -- Será a soma de nUserSeeks + nUserScans + nUserLookups
			    nRankUserUsage bigint NULL,
				nUserSeeks bigint NULL,
				nRankUserSeeks bigint NULL,
			    nUserScans bigint NULL,
			    nRankUserScans bigint NULL,
				nUserLookups bigint NULL, 
				nRankUserLookups bigint NULL, 
		        nUserUpdate bigint NULL,
		        nRankUserUpdate bigint NULL,
		        dLastUser datetime NULL,
		        nIndexLevel tinyint NULL,
		        nIndexDepth tinyint NULL,
		        nAVGFragmentationPercent float NULL,
				cRecommendationIndex varchar(20) null,
		        nFragmentCount bigint NULL,
		        nAVGFragmentationSizePerPage float NULL,
		        nMinRecordSize int NULL,
		        nMaxRecordSize int NULL
   ) 

   
   begin try
   
       if @nOptions = 3 and @cTableName is null and IS_SRVROLEMEMBER('sysadmin',SYSTEM_USER) <> 1  -- IDBUG [00013]
          raiserror('Operação de Detalhamento dos indices para todas as tabelas somente permitido para o perfil de sysadmin.',16,1)
   
       if @cTableName is not null and object_id(@cTableName) is null
          raiserror('Nome da tabela %s não existe.',16,1,@cTableName)
	   
	   set @nIndexID = indexproperty(OBJECT_ID(@cTableName),@cIndexName,'IndexID')
	   
	   -- IDBUG [00008]
	   set @nIndexID = case when @nIndexID = 0 then null else @nIndexID  end 
	   
	   if @cIndexName is not null and @nIndexID is null 
	      raiserror('Nome do indice %s não existe.',16,1,@cIndexName)
	   
	   /*
	   Consiste a tabela Destino (@cResultTable) onde os dados serão gravados.
	   */
	   
       if @cResultTable is not null begin 
           
          if db_name(db_id(parsename(@cResultTable,3))) is null 
             raiserror('Nome do banco de dados da tabela de resultados é inválido.',18,1)	         
          
          if @nOptionsResultTable & 16 = 16 begin
           
             --if select DB_ID('tempdb.dbo.tResult') 
             set @cCommand = 'Drop table '+@cResultTable
			 execute (@cCommand) 
		  end 

		   /*
		   Se a tabela não existe, cria com a estrutura padrão.
		   */       
		   
		   if object_id(@cResultTable )is null begin 
	       
			  set @cCommand = 'CREATE TABLE '+@cResultTable+'(
			            dRecord datetime not null default getdate(),
						cDatabaseName varchar(128) NULL,
						cTableName sysname NOT NULL,
						cName sysname NULL,
						iIndexID int , -- IDBUG [00010]
				        cDescription varchar(210) NULL,
						cKeyColumns varchar(max) NULL,
						cIncludeColumns varchar(max) NULL,
						cFilterDefinition varchar(max) NULL,
						lDisable bit not null default 0,
                        nFillFactor int  null ,
						cFileGroup sysname NOT NULL,
						dStatsUpdate datetime null, 
						cAllocationType varchar(60) NULL,
						nPartitionNumber int NULL,  -- ---- IDBUG [00012]
						cCompression varchar(20)null, 
						nDataPages bigint NULL,
						nSizeInMB  float NULL,
						nRows bigint NULL,
						nUserUsage bigint NULL,
						nRankUserUsage bigint NULL,
						nUserSeeks bigint NULL,
						nRankUserSeeks bigint NULL,
                        nUserScans bigint NULL,
                        nRankUserScans bigint NULL,
				        nUserLookups bigint NULL, 
				        nRankUserLookups bigint NULL, 
						nUserUpdate bigint NULL,
						nRankUserUpdate bigint NULL,
						dLastUser datetime NULL,
						nIndexLevel tinyint NULL,
						nIndexDepth tinyint NULL,
						nAVGFragmentationPercent float NULL,
						cRecommendationIndex varchar(20) null,
						nFragmentCount bigint NULL,
						nAVGFragmentationSizePerPage float NULL,
						nMinRecordSize int NULL,
						nMaxRecordSize int NULL
			            )'
		       
			   execute (@cCommand) 
			 end 
			 
		   else begin 
		   
		      /*
		      Estrutura da tabela @cResultTable não está aproprida para receber os dados.
		      */
		      
		      set @cSchemaSyscolumns = parsename(@cResultTable,3)+'.'+parsename(@cResultTable,2)+'.syscolumns'
		      
		      set @cCommand = '
			     begin try 
		            set nocount on 
				    declare @cColumns varchar(max) 
				    declare @tTMPTb table (name sysname) 
				    insert into @tTMPTb
					-- IDBUG [00001]
				    select name collate SQL_Latin1_General_CP1_CI_AI from tempdb.dbo.syscolumns where id = OBJECT_ID(''tempdb.dbo.#tTMPFdBHelpIndex'') 
				    except 
				    select name from '+@cSchemaSyscolumns +' where id = OBJECT_ID('''+@cResultTable+''')

				    if @@rowcount >= 1 begin 

				       set @cColumns = (
				       select name+'','' as [text()]
   					  	   		    from @tTMPTb
    				 				     for xml path('''')
				       )

				       raiserror(''A definição da estrutura da tabela '+@cResultTable+' é diferente das definições dos dados que serão armazenados. As colunas ausentes são : %s'',16,1,@cColumns)

				    end 
			     end try 
				 begin catch 
		            --select ERROR_MESSAGE(), ERROR_LINE() , ERROR_NUMBER()
                    declare @cMessage varchar(max) = ERROR_MESSAGE()
                    set @cMessage = ''Erro na comparação da estrutura da tabela temporária: '' + @cMessage + '', linha '' + CAST(ERROR_LINE() as varchar(4))
                    raiserror(@cMessage , 16 ,1)		    
				 end catch '
			     
			  execute (@cCommand)
		   
			  if @nOptionsResultTable & 4 = 4 begin
			  
				 set @cCommand = 'Truncate table '+@cResultTable
				 execute (@cCommand) 
				 
			  end
			  
		   end 
       end; 

       /*
       Avaliar para implementar futuramente. 
       Estatistica de compressão de dados. 
       ----------------------------------------------------
       CREATE TABLE #tTMPEstimateDataCompressionSavings
       (
          cObjectName                    varchar(100)
        , cSchemaName                    varchar(50)
        , nIndexId                      int
        , nPartitionNumber              int
        , nSizeCurrentCompression      bigint
        , nSizeRequestedCompression    bigint
        , nSampleCurrentCompression    bigint
        , nSampleRequestedCompression  bigint
       );
       
       if @nOptions >= 1 begin 
       
          insert into #tTMPEstimateDataCompressionSavings
          execute sp_estimate_data_compression_savings null,@cTableName, NULL,NULL,'PAGE';
          
          with cteEstimateDataCompressionSavings as(
          select es.cObjectName , 
              i.name as IndexName , 
		      es.nSizeCurrentCompression, 
		      es.nSizeRequestedCompression, 
              es.nSampleCurrentCompression, 
		      es.nSampleRequestedCompression,
		      cast(((es.nSizeCurrentCompression*1.0/es.nSizeRequestedCompression)-1)*100 as decimal(5,2))as nPercent 
         from #tTMPEstimateDataCompressionSavings as es
         join sys.objects o on es.cObjectName = o.name 
         join sys.indexes i on o.object_id = i.object_id 
          and es.nIndexId = i.index_id 
         ) select cObjectName , 
                  IndexName , 
		          nSizeCurrentCompression, 
		          nSizeRequestedCompression, 
                  nSampleCurrentCompression, 
		          nSampleRequestedCompression,
		          nPercent 
             from cteEstimateDataCompressionSavings
       end 
       ----------------------------------------------------
       */
       
       ;
	   with 
	   cteIndex as (
	     select * , 
	            -- IDBUG [00007] 
	            stats_date(i.object_id, i.index_id) as dStatsUpdate 
	       from sys.indexes i 
	      where ( i.object_id = object_id(@cTableName ) or @cTableName is null) and
		        ( i.index_id = @nIndexID  or @nIndexID is null) and
		        i.object_id > 1000 

	   ),
	   
	   cteColunas as (
		  select ic.object_id ,
				 index_id , 
				 c.name  , 
				 is_descending_key  , 
				 is_included_column , 
				 key_ordinal
			from sys.index_columns ic 
			join sys.columns c 
			  on ic.object_id = c.object_id and  ic.column_id = c.column_id
		  where ( ic.object_id = object_id(@cTableName ) or @cTableName is null) and
		        ( ic.index_id = @nIndexID  or @nIndexID is null ) 
		) ,  
		
		cteColunas2 as (
		   select distinct 
				  object_id , 
				  index_id , 
				  (select '['+name+']' + case when is_descending_key = 1 
											  then 'Desc' 
									 		  else '' 
										 end+',' as [text()]
					 from cteColunas col 
		   			where col.object_id  = cteColunas.object_id 
					and col.index_id =  cteColunas.index_id
					  and col.is_included_column = 0 
					order by key_ordinal
					  for xml path('') 
				  ) as KeyColumns ,
				  (select '['+name +'],' as [text()]
					 from cteColunas col 
		   			where col.object_id  = cteColunas.object_id 
					  and col.index_id =  cteColunas.index_id
					  and col.is_included_column = 1 
					  for xml path('') 
				  ) as IncludeColumns
			 from cteColunas  
	   ) , 
	   
	   cteIndexUsage as (
		  select ROW_NUMBER() over (order by database_id , object_id, index_id) as row, 
			database_id,
			object_id,
			index_id, -- IDBUG [00010]
			-- IDBUG [00002]
			isnull(user_seeks,0) as user_seeks,
			isnull(user_scans,0) as user_scans ,
			isnull(user_lookups,0) as user_lookups,
			isnull(user_updates,0) as user_updates,
			last_user_seek,
			last_user_scan,
			last_user_lookup
			from sys.dm_db_index_usage_stats us  
		  where database_id = db_id()
			 and ( us.object_id = object_id(@cTableName ) or @cTableName is null) 
			 --and ( us.dname = @cIndexName or @cIndexName is null) 
	   ), 
	   
	   cteIndexUsageMaxUsage as (
		  select row, 
				 max(last_user) as LastUser , 
				 max(UserUsage) as UserUsage , 
				 max(user_seeks) as UserSeeks, 
				 max(user_scans) as UserScans , 
				 max(user_lookups) as UserLookups,
				 max(UserUpdate) as UserUpdate 
			from ( select row,
						  last_user_seek as last_user , 
						  user_seeks + user_scans + user_lookups as UserUsage ,
						  user_seeks ,
						  user_scans , 
						  user_lookups,
						  user_updates as UserUpdate
					 from cteIndexUsage
				   union all
				   select row,
						  last_user_scan, 
						  0 ,
						  0 ,
						  0 ,
						  0 ,
						  0 
					 from cteIndexUsage
				   union all
				   select row,
						  last_user_lookup  ,
						  0  , 
						  0  ,
						  0 ,
						  0 ,
						  0 
					 from cteIndexUsage 
				 )  as tabtemp
			group by row
	   ) , 
	   
	   cteIndexAdv as (
		  select p.index_id, 
				 p.object_id,
				 p.data_compression as DataCompression,
				 au.type_desc collate Latin1_General_CI_AI AS AllocationType, 
				 au.data_pages as DataPages, 
				 (au.data_pages * 8)/1024.0 as SizeInMB ,
				 partition_number as nPartitionNumber , ---- IDBUG [00012]
				 rows as nRows,
				 usm.UserUsage, 
				 usm.UserSeeks,
				 usm.UserScans , 
				 usm.UserLookups,
				 usm.UserUpdate,
				 usm.LastUser 
			from sys.allocation_units AS au
			join sys.partitions AS p 
			  on au.container_id = case when au.type in (1,3) 
										then p.partition_id 
							    		else p.hobt_id 
								   end 
			left join cteIndexUsage us  
			  on us.index_id = p.index_id 
			 and us.object_id = p.object_id
			left join cteIndexUsageMaxUsage usm on us.row = usm.row
		   where ( p.object_id = object_id(@cTableName ) or @cTableName is null) 
		         --( c.name = @cIndexName or @cIndexName is null) 
			 and @nOptions >= 1
	   ),
	   
	   cteIndexAdv2 as (
		  select object_id, 
				 index_id , 
				 index_depth as IndexDepth , 
				 index_level as IndexLevel , 
				 alloc_unit_type_desc as AllocationType,
				 avg_fragmentation_in_percent as AVGFragmentationPercent , 
				 fragment_count as FragmentCount , 
				 avg_fragment_size_in_pages as AVGFragmentationSizePerPage ,
				 page_count as DataPages, 
				 (page_count * 8)/1024.0 as SizeInMB , -- IDBUG [00010]
				 record_count as nRows, -- IDBUG [00010]
				 min_record_size_in_bytes as MinRecordSize ,
				 max_record_size_in_bytes as MaxRecordSize 
			from sys.dm_db_index_physical_stats(db_id(), object_id(@cTableName ),@nIndexID, null,@cMode )
			where @nOptions >= 2
	   ) , 
	   
	   cteResult as (
	   select distinct 
			  i.object_id ,
			  i.index_id,
			  sc.name + '.'+o.name as TableName,  -- IDBUG [00011]
			  isnull(i.name,i.type_desc) as Name , 
			  convert(varchar(210), 
					case when i.index_id = 1 and i.type = 1 then 'Clustered' 
						 when i.index_id > 1 and i.type = 6 then 'Nonclustered Columnstore' 
						 when i.index_id > 1 and i.type = 2 then 'Nonclustered' 
						 else 'Heap' 
					end + 
					case when ignore_dup_key <> 0 
						 then ', Ignore duplicate keys' 
						 else '' 
					end + 
					case when is_unique=1 
						 then ', Unique' 
						 else '' 
					end + 
					case when is_hypothetical <>0 
						 then ', Hypothetical' 
						 else '' 
					end + 
					case when is_primary_key <> 0 
						 then ', Primary Key' 
						 else '' 
					end + 
					case when is_unique_constraint <> 0 
						 then ', Unique Key' 
						 else '' 
					end + 
					case when i.auto_created <>0 
						 then ', Auto Create' 
						 else '' 
					end + 
					case when no_recompute <>0 
						 then ', Stats no recompute' 
						 else '' 
					end)
					as Description , 
			  ic.KeyColumns, 
			  ic.IncludeColumns,  
			  i.filter_definition as FilterDefinition ,   
			  -- IDBUG [00009]
			  i.is_disabled as lDisable,
			  i.fill_factor as IndexFillFactor , 
			  ds.name as FileGroup ,
			  i.dStatsUpdate ,
			  case ia.DataCompression  
			       when 0 then 'None ' 
			       when 1 then 'Row  ' 
			       when 2 then 'Page '
			       else 'Other'  
			  end DataCompression  ,
			  ia.nPartitionNumber ,  -- IDBUG [00012]
			  ia.AllocationType ,
			  isnull(ia2.DataPages ,ia.DataPages ) as DataPages , -- IDBUG [00010]
			  isnull(ia2.SizeInMB,ia.SizeInMB) as SizeInMB, -- IDBUG [00010]
			  isnull(ia2.nRows,ia.nRows) as nRows, -- IDBUG [00010]
			  ia.UserUsage,
			  ia.UserSeeks,
			  ia.UserScans , 
			  ia.UserLookups,
			  ia.UserUpdate,
			  ia.LastUser,
			  ia2.IndexLevel ,
			  ia2.IndexDepth ,
			  ia2.AVGFragmentationPercent,
			  case when (ia2.AVGFragmentationPercent > 10)  then 'Rebuild' 
			       when (ia2.AVGFragmentationPercent <= 10) then 'Reorganize' 
			       else null 
			  end as cRecommendationIndex,
			  ia2.FragmentCount ,
			  ia2.AVGFragmentationSizePerPage,
			  ia2.MinRecordSize ,
			  ia2.MaxRecordSize
		 from cteIndex /*sys.indexes*/ i 
		 left join cteColunas2 ic 
		   on i.object_id = ic.object_id  
		  and i.index_id = ic.index_id  
		 join sys.data_spaces ds 
		   on i.data_space_id = ds.data_space_id 
		 join sys.objects o 
		   on i.object_id = o.object_id 
		 join sys.schemas sc  -- IDBUG [00011]
		   on o.schema_id = sc.schema_id 
		 left join sys.stats s
		   on i.object_id = s.object_id 
		  and i.index_id = s.stats_id 
		 left join cteIndexAdv ia 
		   on i.object_id = ia.object_id 
		  and i.index_id = ia.index_id
		 left join cteIndexAdv2 ia2 
		   on ia2.object_id = ia.object_id 
		  and ia2.index_id = ia.index_id
		  and ia2.AllocationType = ia.AllocationType
		where o.type not in ('S','IT','TF') -- IDBUG [00006]
	   )
	   insert into #tTMPFdBHelpIndex (cDatabaseName, cTableName, cName, iIndexID ,cDescription, cKeyColumns, 
											  cIncludeColumns, cFilterDefinition, lDisable ,nFillFactor , cFileGroup, dStatsUpdate , cCompression , nPartitionNumber , cAllocationType, 
											  nDataPages, nSizeInMB ,nRows, 
											  nUserUsage, nRankUserUsage, 
											  nUserSeeks, nRankUserSeeks,
											  nUserScans, nRankUserScans,
											  nUserLookups ,  nRankUserLookups ,
											  nUserUpdate, nRankUserUpdate, 
											  dLastUser, nIndexLevel, 
											  nIndexDepth, nAVGFragmentationPercent, cRecommendationIndex , nFragmentCount, nAVGFragmentationSizePerPage, 
											  nMinRecordSize, nMaxRecordSize)
    
	   select db_name() as DatabaseName,
	          TableName,
		      Name,
		      index_id,
			  Description,
			  KeyColumns,
			  IncludeColumns,
			  FilterDefinition,
			  -- IDBUG [00009]
			  lDisable,
			  IndexFillFactor,
			  FileGroup,
			  dStatsUpdate,
			  DataCompression ,
			  nPartitionNumber, -- IDBUG [00012]
			  AllocationType,
			  DataPages,
			  SizeInMB ,
			  nRows,
			  UserUsage,
			  -- IDBUG [00005]
			  RANK() over (order by UserUsage) as nRankUserUsage, 
			  UserSeeks , 
			  RANK() over (order by UserSeeks) as nRankUserSeeks, 
			  UserScans ,
			  RANK() over (order by UserScans) as nRankUserScans, 
			  UserLookups ,
			  RANK() over (order by UserLookups) as nRankUserLookups, 
			  UserUpdate,
			  RANK() over (order by UserUpdate) as nRankUserUpdate, 
			  LastUser,
			  IndexLevel,
			  IndexDepth,
			  AVGFragmentationPercent,
			  cRecommendationIndex,
			  FragmentCount,
			  AVGFragmentationSizePerPage,
			  MinRecordSize, 
			  MaxRecordSize
		 from cteResult
	    --where (object_id = object_id(@cTableName ) or @cTableName is null) 
	     order by cteResult.TableName, cteResult.index_id 
	     
	   if @cResultTable is not null begin 
		   set @cCommand = 'Insert into '+ @cResultTable +'
											 (cDatabaseName, cTableName, cName, iIndexID  ,cDescription, cKeyColumns, 
												  cIncludeColumns, cFilterDefinition, lDisable , nFillFactor, cFileGroup, dStatsUpdate,cCompression  , nPartitionNumber , cAllocationType, 
												  nDataPages, nSizeInMB , nRows, 
												  nUserUsage, nRankUserUsage, 
											      nUserSeeks, nRankUserSeeks,
											      nUserScans, nRankUserScans,
											      nUserLookups ,  nRankUserLookups,
											      nUserUpdate, nRankUserUpdate, 
												  dLastUser, nIndexLevel, 
												  nIndexDepth, nAVGFragmentationPercent, cRecommendationIndex, nFragmentCount, nAVGFragmentationSizePerPage, 
												  nMinRecordSize, nMaxRecordSize) 
									   select cDatabaseName, cTableName, cName, iIndexID  , cDescription, cKeyColumns, 
												  cIncludeColumns, cFilterDefinition, lDisable , nFillFactor, cFileGroup, dStatsUpdate ,cCompression  , nPartitionNumber ,cAllocationType, 
												  nDataPages, nSizeInMB , nRows, 
											      nUserUsage, nRankUserUsage, 
											      nUserSeeks, nRankUserSeeks,
											      nUserScans, nRankUserScans,
											      nUserLookups ,  nRankUserLookups ,
											      nUserUpdate, nRankUserUpdate, 
												  dLastUser, nIndexLevel, 
												  nIndexDepth, nAVGFragmentationPercent, cRecommendationIndex, nFragmentCount, nAVGFragmentationSizePerPage, 
												  nMinRecordSize, nMaxRecordSize 
										 from #tTMPFdBHelpIndex'
		   execute sp_executesql @cCommand 
	   end ;
	   
	   if @nOptions = 0 and @nOptionsResultTable & 8 = 8
	      select cDatabaseName, cTableName, cName, cDescription, cKeyColumns, 
				 cIncludeColumns, cFilterDefinition, nFillFactor , cFileGroup 
			from #tTMPFdBHelpIndex 
			order by cTableName, iIndexID , nIndexLevel
			
	   if @nOptions = 1  and @nOptionsResultTable & 8 = 8
	   	  select cDatabaseName, cTableName, cName, cDescription, cKeyColumns, 
				 cIncludeColumns, cFilterDefinition, lDisable,nFillFactor, cFileGroup ,dStatsUpdate , cCompression ,nPartitionNumber ,cAllocationType, 
				 nDataPages, nSizeInMB , nRows, nUserUsage, nRankUserUsage, nUserUpdate, nRankUserUpdate , dLastUser --, datediff(d ,@dStartSQLServer,dLastUser )
			from #tTMPFdBHelpIndex 
			order by cTableName, iIndexID , nIndexLevel
			 
	   if @nOptions = 2   and @nOptionsResultTable & 8 = 8
	   	  select cDatabaseName, cTableName, cName, cDescription, cKeyColumns, 
				 cIncludeColumns, cFilterDefinition, lDisable, nFillFactor , cFileGroup ,dStatsUpdate ,cCompression ,nPartitionNumber ,cAllocationType, 
				 nDataPages, nSizeInMB , nRows, 
				 nUserUsage, nRankUserUsage, 
				 nUserSeeks, nRankUserSeeks,
				 nUserScans, nRankUserScans,
				 nUserLookups ,  nRankUserLookups ,
				 nUserUpdate, nRankUserUpdate, 
				 dLastUser , nIndexLevel, 
				 nIndexDepth, nAVGFragmentationPercent, cRecommendationIndex, nFragmentCount, nAVGFragmentationSizePerPage
			from #tTMPFdBHelpIndex 
			order by cTableName, iIndexID , nIndexLevel
			
 	   if @nOptions = 3 and @nOptionsResultTable & 8 = 8
 	      select * 
 	        from #tTMPFdBHelpIndex
 	        order by cTableName, iIndexID ,cAllocationType , nIndexLevel DESC -- IDBUG [00010]

   end try 

   begin Catch 
        declare @cMessage varchar(max) = ERROR_MESSAGE()
        set @cMessage = 'Mensagem de erro: ' + @cMessage + ' :: Objeto '+ ERROR_PROCEDURE() + ' :: linha ' + CAST(ERROR_LINE() as varchar(10))+' :: Código Erro '+ CAST(ERROR_NUMBER() as varchar(10))
        raiserror(@cMessage , 16 ,1)
   end Catch 

   -- IDBUG [00011]   
   if @nValorAnsiWarnigns = 0
      set ansi_warnings off 
   else 
      set ansi_warnings on 

end 

go 
sp_MS_marksystemobject 'sp_HelpIndex2'
go
GRANT EXECUTE ON [dbo].[sp_HelpIndex2] TO [public]
