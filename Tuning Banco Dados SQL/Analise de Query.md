Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Ferramentas para medir e analisar queries

## Ativar ou desativar (on, off) as estatísticas da query
```sql
set statistics io on
set statistics time on 

--Caso nao esteja em ambiente de produção recomenda-se limpar o fuffer e a cache
DBCC DROPCLEANBUFFERS 
DBCC FREEPROCCACHE 
```

## Habilitar a ferramenta nativa do SSMS
(Query -> Include Client Statistics) 

## Plano de execução estimado e real
Para ativar o estimado (antes de realizar a query) Ctrl + L ou no menu do SSMS clique no botão (Display Extimated Execution Plan)
Para ativar o real (após de realizar a query) Ctrl + M ou no menu do SSMS clique no botão (Include Actual Execution Plan)

Devemos evitar os operadores:
- Table Scan (Tabela sem index - Varre toda a tabela)
- Index Scan (Varre toda a tabela)
- Sort (Ordenar os dados sem necessidade real)
- RID Lookup (Heap - RID busca dados que são pedidos na query mas não possuem index)
- Compute Scalar (Operação matemática na consulta)

## (Profile) Ferramenta para monitorar eventos no SSMS 
Cuidado: Essa ferramenta é custosa para o banco, prefira usar o Extended Events (próximo subtitulo)

No SSMS Tools -> SQL Server Profile

Eventos:
- Execuções de comandos SELECT, INSERT, UPDATE e DELETE
- Conexões, desconexões e falhas
- Bloqueios criados e liberados
- Aumento e Redução do banco de dados
- Mensagens de erros e avisos

Dica, nas opções de escolha do profile, ative T-SQL -> SQL:StmtCompleted (Indica que uma instrução Transact-SQL foi concluída), utiliza o filtro com o valor do SPID (Id da tela atual de query no SSMS (select @@SPID))

## Extended Events
Alternativa menos custosa em relação ao profile

Extended Events é uma arquitetura do SQL SERVER que permite coletar as informações necessárias sobre os eventos em execução
para solucionar ou identificar problemas de desempenho. Para iniciar a análise, crie a pasta C:\XE, os arquivos gerados terão a extensão .XEL

```sql
Create or Alter Procedure stp_RastreamentoXE_Para_Statement_Completed 
@cSession varchar(255) as
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
```
Inicie o evento:
```sql
Alter Event Session Monitor on Server State = Start 
go
```
Realize a query que deseja analisar Ex.:
```sql
SELECT name, street from client WHERE id = 201231 
```
Execute a procedure e analise o resultado
```sql
execute stp_RastreamentoXE_Para_Statement_Completed  'Monitor'
```
Interrompa o monitoramento
```sql
Alter Event Session Monitor on Server State = Stop
go
```

-----------------------------------------------------

Outra alternativa seria transformar os dados em xml e analisá-los, no entanto, essa operação é mais custosa

Crie o evento (para queries completadas):
```sql
Create Event Session Monitor On server 
   Add Event sqlserver.sql_statement_completed
   Add Target package0.event_file ( Set filename = 'C:\XE\Monitor.xel')
GO
```
Inicie o evento:
```sql
Alter Event Session Monitor on Server State = Start 
go
```
Realize a query que deseja analisar Ex.:
```sql
SELECT name, street from client WHERE id = 201231 
```
Transforme os dados gerados em XML
```sql
Select convert(xml, event_data) AS xData
  From sys.fn_xe_file_target_read_file('C:\XE\Monitor*.xel',null,null,null)
go
```
Pare o evento
```sql
With cteDados as (Select OBJECT_NAME AS cEvent, 
        CONVERT(XML, event_data) AS xData,
		    cast(SWITCHOFFSET(timestamp_utc ,'-03:00') as datetime) as dDateTime 
        From sys.fn_xe_file_target_read_file('C:\XE\Monitor*.xel',null,null,null)),
   cteDadosFormatados  as (
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
Select * From cteDadosFormatados where cComando like '%tItemMovimento%' --Remover essa linha caso queira ver todos os eventos
```
Apague a sessão
```sql
Drop Event Session Monitor 
On Server
```
