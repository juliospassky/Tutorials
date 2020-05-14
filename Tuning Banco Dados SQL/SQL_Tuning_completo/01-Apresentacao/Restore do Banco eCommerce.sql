/*
Restore e Configuracao do banco de dados eCommerce
*/

/*
Teste para verificar se o backup do banco de dados está correto.
*/
RESTORE FILELISTONLY FROM DISK = 'C:\Database\BackupFiles\eCommerce_v12-5-01.bkp' 
RESTORE VERIFYONLY FROM DISK   = 'C:\Database\BackupFiles\eCommerce_v12-5-01.bkp' 
go


/*

*/
use Master
go

if exists (select name from sys.databases where name = 'eCommerce')
   ALTER DATABASE eCommerce set single_user with rollback immediate 

GO

RESTORE DATABASE [eCommerce] 
FROM DISK = 'C:\Database\BackupFiles\eCommerce_v12-5-01.bkp'
WITH 
MOVE 'eCommercePrimary' TO 'C:\Database\DataBaseFiles\eCommercePrimary.mdf',
MOVE 'eCommerceHistorico' TO 'C:\Database\DataBaseFiles\eCommerceHistorico.ndf',
MOVE 'eCommerceTransacional' TO 'C:\Database\DataBaseFiles\eCommerceTransacional.ndf',
MOVE 'eCommerceIndicesHistorico' TO 'C:\Database\DataBaseFiles\eCommerceIndicesHistorico.ndf',
MOVE 'eCommerceIndicesTransacional' TO 'C:\Database\DataBaseFiles\eCommerceIndicesTransacional.ndf',
MOVE 'eCommerceLog' TO 'C:\Database\LogFiles\eCommerceLog.ldf',
NOUNLOAD,  STATS = 1 , REPLACE 
go

use eCommerce
go

drop index if exists idxStatus on tMovimento
go

Create Index idxStatus on tMovimento (dValidade,dMovimento,cStatus,cTipo) 
Include ( cCodigo,nSequencia,mValor, mDesconto, mICMS)
with (online= on) on IndicesTransacionais
go

Drop Index if exists idxStatus2 on tMovimento 
go

Create Index idxStatus2 on tMovimento (cStatus,dMovimento) with (online = on) on IndicesTransacionais
go

drop Index if exists idciIDItem on tItemMovimento
go

Create Clustered Index idciIDItem on tItemMovimento (iidItem) on IndicesTransacionais
go

Drop Index if exists idxiIDMovimento on tItemMovimento
go

Create Index idxiIDMovimento on tItemMovimento (iidMovimento) include (iidProduto,nQuantidade,mPreco) on IndicesTransacionais
go

Drop Index if exists idxCodigo on tMovimento
go

Create Index idxCodigo on tMovimento (cCodigo) on INDICESTRANSACIONAIS
go

/*
set nocount on 

declare @dUltima datetime
select @dUltima = max(dMOvimento) from tmovimento 

update tCADParametro set dDataPartida = @dUltima
update tCADParametro set dDataTermino = getdate()
update tCADparametro set nDebug = 0
update tCADParametro set nNFDias = 400 , nVariacaoNF = 50
update tCADParametro set nOperacoes = 500 , nPedidosDias = 450 , nVariacaoPedido = 20 , nCancPedidosDias = 40 , nVariacaoCancPedido = 10
go

execute stp_Carga2
go
*/


/*
Ajusta Estoque de produtos com saldo Negativo 
*/

update tProduto set nEstoque=0 where nEstoque < 0
go
;
with cteMov as (
   select top 1 percent * from tItemMovimento order by newid()
)
update cteMov set iidProduto = 2570
go

/*
Colocar null para Data Estimada dos Movimento cancelados.
Utilizado para a aula de NOT NULL x NULL
*/
use eCommerce
go

update tMovimento set dEntregaEstimada = null where cTipo = 'PD' and cStatus = 'C'
go

/*
Ajuste o codigo externo do produto, passando para NULL quando for ''
*/

use eCommerce
go
update tProduto set cCodigoExterno = null where cCodigoExterno = ''
go

/*
Atualiza estatisticas de todos os indices 
*/
use eCommerce
go
sp_msforeachtable 'update statistics ? with fullscan'
go



Use Master
go

alter database DBDemo set single_user with rollback immediate 
go

drop database if exists  DBDemo
go

Create Database DBDemo
go

Alter Database DBDemo SET MIXED_PAGE_ALLOCATION ON



use DBDemo
go

--select * from vDataTypes

Create or Alter view vDataTypes 
as 
select system_type_id , 
case when system_type_id  in (104,127,56,52,48,60,122) then 'Numerico Exato'
     when system_type_id  in (35,99) then 'Large Object - LOB'
     when system_type_id  in (40,41,42,43,58,61) then 'Data e Hora '
     when system_type_id  in (62,59) then 'Numérico Aproximado'
     when system_type_id  in (106,108) then 'Numérico com precisão'
     when system_type_id  in (167) then 'Comprimento variável'
     when system_type_id  in (175) then 'Comprimento fixo'
     when system_type_id  in (231) then 'Comprimento variável UNICODE'
     when system_type_id  in (239) then 'Comprimento fixo UNICODE'
     when system_type_id  in (173,165,34) then 'Binária '
     else 'Outros tipos' 
     end Grupo ,
Name, 
case when name in ('nvarchar','nchar' ) then 4000 else  max_length end  max_length , precision , scale  
from sys.types
where is_user_defined = 0 and user_type_id <> 256
union all
select 0 , 'Large Value ', 'varchar(max)', -1, 0,0
union all
select 0 , 'Large Value ', 'nvarchar(max)', -1, 0,0
union all
select 0 , 'Large Object - LOB', 'varbinary(max)', -1, 0,0
go

