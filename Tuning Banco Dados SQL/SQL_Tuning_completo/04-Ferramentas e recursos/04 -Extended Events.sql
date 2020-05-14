/*
Extended Events ou eventos extendidos é uma arquitetura do SQL SERVER que 
permite coletar as informações necessárias sobre os eventos em execução
para solucionar ou identificar problemas de desempenho.

Basicamente ele utiliza os mesmo conceitos do Profiler, entretando ele 
executa utilizando consumindo recursos de servidor e da instância bem menores
que o Profiler.  

Ele tem o acesso por interface gráfica. Na Object Explorer, expandir o nó da Instância.
Depois expande o nó Management e acesso Extend Events.

Você também pode criar o evento através de comandos T-SQL

No exemplo abaixo, nós vamos :

   - Criar uma Sessão do Extended Event de nome xeMonitora_eCommerce.
   - Definir um evento para monitorar que no caso serão todos os comandos completados. 
   - Definir o local destino onde os dados capturados serão gravados.
     No caso, será um arquivo de extensão .XEL que nesse caso será gravado em C:\XE (Lembre-se de criar a pasta!!) 
   - Iniciar o evento de monitoramento. 
   - Aguarde até capturar os comandos. 
   - Parar o evento de monitoramento.
   - Acessar os dados capturados. 

*/

Create Event Session xeMonitora_eCommerce 
    On server 
   Add Event sqlserver.sql_statement_completed
   Add Target package0.event_file 
      (
         Set filename = 'C:\XE\xeMonitora_eCommerce.xel'
      )
GO

-- Quais os eventos quem existem para o SQL Server?


Select pack.name as cPackage ,
       obj.name as cEvent, 
       obj.description cDescriptionEvent  
  From sys.dm_xe_packages pack
  join sys.dm_xe_objects obj 
    on pack.guid = obj.package_guid
 where obj.object_type = 'Event'
   and pack.name = 'sqlserver'
 order by cEvent 

/*
Iniciar a execução do Evento xeMonitor_eCommerce.
O arquivo xeMonitor_eCommerce_x_XXXXXXXXXXXXXXXXXX.xel é criado no disco. 
Se você parar a execução do evento e iniciar novamente, um novo arquivo
iniciado com xeMonitor1 será criado. 
*/

Alter Event Session xeMonitora_eCommerce 
   on Server
State = Start 
go

/*
Atenção !!!
Abriar o arquivo 04a - Apoio Extended Events e executar todos os comandos. 
Esses comandos serão capturados pelo evento xeMonitor
*/


/*
Contagem de ocorrências. A atualização é um processo assíncromo. 
*/

Select COUNT(1) 
  From sys.fn_xe_file_target_read_file('C:\XE\xeMonitora_eCommerce*.xel',null,null,null)


Select *
  From sys.fn_xe_file_target_read_file('C:\XE\xeMonitora_eCommerce*.xel',null,null,null)
go


Select convert(xml, event_data) AS xData
  From sys.fn_xe_file_target_read_file('C:\XE\xeMonitora_eCommerce*.xel',null,null,null)
go

/*
Parar a execução do evento xeMonitor1
*/
Alter Event Session xeMonitora_eCommerce
   on Server
 State = Stop 
go

/*
Fazendo a leitura do dados a partir da coluna com dados XML.
*/

;
With cteDados as (
   Select OBJECT_NAME AS cEvent, 
          CONVERT(XML, event_data) AS xData,
	       cast(SWITCHOFFSET(timestamp_utc ,'-03:00') as datetime) as dDateTime
     FROM sys.fn_xe_file_target_read_file('C:\XE\xeMonitora_eCommerce*.xel',null,null,null)
)
Select cEvent, 
       xData,
	    dDateTime as dDataHora,
       xData.value('(/event/data[@name=''duration'']/value)[1]','int')/1000000.0  as nDuracaoSeg,
       xData.value('(/event/data[@name=''cpu_time'']/value)[1]','int')            as nCPU,
       xData.value('(/event/data[@name=''logical_reads'']/value)[1]','int')       as nLeituraLogical,
       xData.value('(/event/data[@name=''physical_reads'']/value)[1]','int')      as nLeituraFisica,
       xData.value('(/event/data[@name=''writes'']/value)[1]','int')              as nEscrita,
       xData.value('(/event/data[@name=''row_count'']/value)[1]','int')           as nLinhas,
       xData.value('(/event/data[@name=''statement'']/value)[1]','varchar(max)')  as cComando
  FROM cteDados
 Order by dDataHora

/*
Somente visualizando os comandos com a tabela tMovimento 
*/
;
With cteDados as (
   Select OBJECT_NAME AS cEvent, 
          CONVERT(XML, event_data) AS xData,
		    cast(SWITCHOFFSET(timestamp_utc ,'-03:00') as datetime) as dDateTime 
     From sys.fn_xe_file_target_read_file('C:\XE\xeMonitora_eCommerce*.xel',null,null,null)
) , cteDadosFormatados  as (
   Select cEvent ,
          xData,
          dDateTime,
          xData.value('(/event/data[@name=''duration'']/value)[1]','int')/1000000.0  as nDuracaoSeg,
          xData.value('(/event/data[@name=''cpu_time'']/value)[1]','int')            as nCPU,
          xData.value('(/event/data[@name=''logical_reads'']/value)[1]','int')       as nLeituraLogical,
          xData.value('(/event/data[@name=''physical_reads'']/value)[1]','int')      as nLeituraFisica,
          xData.value('(/event/data[@name=''writes'']/value)[1]','int')              as nWrite,
          xData.value('(/event/data[@name=''row_count'']/value)[1]','int')           as nLinhas,
          xData.value('(/event/data[@name=''statement'']/value)[1]','varchar(max)')  as cComando
     From cteDados
)
Select * 
  From cteDadosFormatados 
  where cComando like '%tItemMovimento%'

/*
Apagar uma Sessão 
*/

Drop Event Session xeMonitora_eCommerce 
On Server 

------------------------------------


/*
Aplicando filtro em um evento.
*/

-- Drop Event Session xeMonitor_tMovimento on Server 

Create Event Session xeMonitor_tMovimento 
    On server 
   Add Event sqlserver.sql_statement_completed 
   (
      Where 
      (
         statement like '%tItemMovimento%'
      )
   ) 
   Add Target package0.event_file 
   (
      Set filename = 'C:\XE\xeMonitor_tMovimento.xel'
   )

GO

/*
Iniciar a Sessão
*/

Alter Event Session xeMonitor_tMovimento 
   on Server
State = Start 
go


/*
*/
;
With cteDados as (
   Select OBJECT_NAME AS cEvent, 
          CONVERT(XML, event_data) AS xData,
	       cast(SWITCHOFFSET(timestamp_utc ,'-03:00') as datetime) as dDateTime
     FROM sys.fn_xe_file_target_read_file('C:\XE\xeMonitor_tMovimento*.xel',null,null,null)
)
Select cEvent, 
       xData,
	    dDateTime as dDataHora,
       xData.value('(/event/data[@name=''duration'']/value)[1]','int')/1000000.0  as nDuracaoSeg,
       xData.value('(/event/data[@name=''cpu_time'']/value)[1]','int')            as nCPU,
       xData.value('(/event/data[@name=''logical_reads'']/value)[1]','int')       as nLeituraLogical,
       xData.value('(/event/data[@name=''physical_reads'']/value)[1]','int')      as nLeituraFisica,
       xData.value('(/event/data[@name=''writes'']/value)[1]','int')              as nEscrita,
       xData.value('(/event/data[@name=''row_count'']/value)[1]','int')           as nLinhas,
       xData.value('(/event/data[@name=''statement'']/value)[1]','varchar(max)')  as cComando
  FROM cteDados
 Order by dDataHora


/*
*/
Alter Event Session xeMonitor_tMovimento 
   on Server
State = Stop
go



/*
Por que usar o Extend Eventos no lugar do Profiler.

- Profiler é um interface pesada que consume muitos recurso do servidor.
- O total de eventos cobertos pelo Extended Event é bem maior que o Profiler.
- A programação do Extended Events é baseada em T-SQL enquanto o Profiler é somente Store Procedure.
- A Microsoft vem anunciando a desativação do Profiler. 

*/


/*
Automatizando a visualização do rastreamento. 
*/

Create or Alter Procedure stp_RastreamentoXE_Para_Statement_Completed 
@cSession varchar(255)
as
begin 
   
   Declare @cfile varchar(255) = '' ;

   With cteTarget as (
      select CAST(t.target_data as xml) as xtarget_data
        from sys.dm_xe_sessions as s 
        join sys.dm_xe_session_targets as t
          on s.address = t.event_session_address
       where s.name = @cSession 
   )
   Select @cfile = Target.cFile.value('(@name)[1]','varchar(255)') 
     From cteTarget 
      Cross Apply xtarget_data.nodes('EventFileTarget/File') as Target (cFile);

   if @cfile <> '' 

      With cteDados as (
         Select OBJECT_NAME AS cEvent, 
                CONVERT(XML, event_data) AS xData,
		          cast(SWITCHOFFSET(timestamp_utc ,'-03:00') as datetime) as dDateTime
           FROM sys.fn_xe_file_target_read_file(@cfile,null,null,null)
      )
      Select cEvent,
	          dDateTime,
             xData.value('(/event/data[@name=''duration'']/value)[1]','int')/1000000.0  as nDuracaoSeg,
             xData.value('(/event/data[@name=''cpu_time'']/value)[1]','int')            as nCPU,
             xData.value('(/event/data[@name=''logical_reads'']/value)[1]','int')       as nLeituraLogical,
             xData.value('(/event/data[@name=''physical_reads'']/value)[1]','int')      as nLeituraFisica,
             xData.value('(/event/data[@name=''writes'']/value)[1]','int')               as nWrite,
             xData.value('(/event/data[@name=''row_count'']/value)[1]','int')          as nLinhas,
             xData.value('(/event/data[@name=''statement'']/value)[1]','varchar(max)')  as cComando
        FROM cteDados
        
end 
go
/*
*/


Alter Event Session xeMonitor_tMovimento 
on Server
State = Start 
go


execute stp_RastreamentoXE_Para_Statement_Completed  'xeMonitor_tMovimento'



Alter Event Session xeMonitor_tMovimento 
on Server
State = Stop
go
