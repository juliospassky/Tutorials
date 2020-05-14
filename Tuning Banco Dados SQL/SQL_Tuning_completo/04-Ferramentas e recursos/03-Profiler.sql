/*
Profiler - Ferramenta para rastrear eventos que ocorrem  
no lado do servidor de banco de dados.

Ref.: https://docs.microsoft.com/pt-br/sql/tools/sql-server-profiler/sql-server-profiler?view=sql-server-2017

Eventos:

São ações criadas por um instância do SQL SERVER, como :

- Conexões, desconexões e falhas;
- Bloqueios criados e liberados;
- Aumento e Redução do banco de dados;
- Mensagens de erros e avisos.
- Execuções de comandos SELECT, INSERT, UPDATE e DELETE.
.... 

Os eventos são agrupados em classes de eventos. 

A classe de eventos TSQL, por exemplo, tem os seguintes eventos:

Exec Prepared SQL	   Indica que SqlClient, ODBC, OLE DB ou DB-Library 
					   executou uma ou mais instruções Transact-SQL preparadas.
Prepare SQL			   Indica que SqlClient, ODBC, OLE DB ou DB-Library preparou uma ou mais instruções Transact-SQL para uso.
SQL:BatchCompleted	   Indica que o lote Transact-SQL foi concluído.
SQL:BatchStarting	   Indica que o lote Transact-SQL está iniciando.
SQL:StmtCompleted	   Indica que uma instrução Transact-SQL foi concluída.
SQL:StmtRecompile	   Indica recompilações em nível de instrução causadas por todos os tipos de lotes: procedimentos armazenados, gatilhos, lotes ad hoc e consultas.
SQL:StmtStarting	   Indica que uma instrução Transact-SQL está iniciando.
Unprepare SQL		   Indica que SqlClient, ODBC, OLE DB ou DB-Library excluiu uma ou mais instruções Transact-SQL preparadas.
XQuery Static Type	   Ocorre quando o SQL Server executa uma expressão XQuery.

Coluna de dados 
---------------

Atributo de uma classe de eventos que foi rastreado pelo Profiler.
Nem todas as colunas são aplicadas para as classes de eventos.
Alguns colunas importantes para o evento "SQL:StmtCompleted"

SPID		   Identificação da Sessão
CPU			Tempo da CPU (em milissegundos) usado pelo evento.	
Duração		Período de tempo (em microssegundos) utilizado pelo evento.	
Reads		   Número de leituras de página emitidas pela instrução SQL.	
RowCounts	Número de linhas afetadas por um evento.	
TextData	   Texto da instrução que foi executada.	
Writes		Número de gravações de páginas emitidas pela instrução SQL.	

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/event-classes/sql-stmtcompleted-event-class?view=sql-server-2017


Filtros

Utilizados para reduzir a quantidade de eventos que são capturados.
Ele são criados com base nas colunas de dados e utilizam as regras
de condições e expressões padrão.

Vamos a prática. 

*/

select @@SPID

use eCommerce
go

select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) and iIDCliente <= cast(rand()*200000 as int)
go

Select * from tProduto 
where iIDCategoria = 16
go


declare @data datetime 

select top 1 @data = dEntregaRealizada 
  from tMovimento  
  where dEntregaRealizada  is not null 
  order by iIDMovimento desc 

set statistics io on 

Select * from tMovimento 
   join tItemMovimento on tMovimento.iIDMovimento = tItemMovimento.iIDMovimento
where dEntregaRealizada = @data

set statistics io off
go


/*
Table 'tItemMovimento'. Scan count 1, logical reads 3341, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tMovimento'.		Scan count 1, logical reads 683, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

select 4455 + 2616
*/






/*
Criando um Template para as próximas aulas.
*/

