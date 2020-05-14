/*
Nomear Procedure com o SP_ 

- No site da Microsoft, eles aconselham que você não nomeie suas store procedures com o prefixo 'sp_'.
  De acordo com eles, procedures iniciadas com sp_ são designadas como objetos de sistemas.

  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/statements/create-procedure-transact-sql?view=sql-server-2017#arguments

- Quando você está conectado em um banco de dados que não seja o banco de dados MASTER e executa uma 
  procedure do sistema que inicia com 'sp_' (sp_help, por exemplo), o SQL Server realizará a pesquisa 
  no banco de dados MASTER para identificar a procedure, retorna a conexão para o contexto do seu 
  banco de dados e termina de executar a procedure.
*/


use eCommerce
go
sp_help 'tCliente' 
go

use eCommerce
go
execute sp_help 'tCliente' 
go

use eCommerce
go
execute eCommerce.dbo.sp_help 'tCliente' 
go


/*

- Quando você cria uma procedure no seu banco de dados com o prefixo 'sp_' (por exemplo, SP_HORAATUAL) 
  e executa essa procedure, o SQL SERVER realizará a pesquisa no banco de dados MASTER. Como ele não 
  acha a procedure neste banco, o SQL SERVER retorna a conexão para o seu banco de dados, pesquisa 
  a procedure nesse banco e a executa. 

*/

use eCommerce
go

Create or Alter Procedure sp_HoraAtual 
as
begin
   select GETDATE()
end 
go

sp_HoraAtual 


/*

- Para evitar esse sobrecarga no processamento, voce deve definir um padrão de nome de procedures 
  (nomenclatura de objetos de banco de dados) que não começe com 'sp_'.

- Imagine um banco de dados com mais de 100 procedures distintas sendo executadas cada uma milhares 
  de milhares de vezes durante um período de tempo.

*/

use eCommerce
go

execute sp_help 'tCliente'
go

Select * 
  from sys.objects
 Where name = 'sp_help'
go



Select * 
  from sys.system_objects 
 Where name = 'sp_help'
go


/*
Criando um objeto no banco eCommerce, com o mesmo nome que existe no MASTER.
*/
use eCommerce
go
Create or Alter Procedure sp_help
@cObjeto varchar(100)
as
begin
    Select 'Esse objeto não é a SP_HELP'
end 
go

Select * 
  From sys.objects 
 Where name = 'sp_help'

Select m.definition 
  From sys.sql_modules m
  join sys.procedures p 
    on m.object_id = p.object_id 
  where p.name = 'sp_help'
go

sp_help 'tCliente'
go

execute sp_help 'tCliente'
go

execute  eCommerce.dbo.sp_help 'tCliente'
go


/*
Criando a procedure stp_help, idêntica a criada acima. 
*/
use eCommerce
go

Create or Alter Procedure stp_help
@cObjeto varchar(100)
as
begin
    Select 'Esse objeto não é a SP_HELP'
end 
GO

execute stp_help 'tCliente'
go


/*
Criando uma procedure que não existe no master, mas existe no banco eCommerce, com o nome
sp_ 
*/
use eCommerce
go

Create or Alter Procedure sp_Ajuda
@cObjeto varchar(100)
as
begin
    Select 'Esse objeto não é a SP_HELP'
end 
GO

execute sp_Ajuda 'tCliente'
go




/*
Teste de carga

- Esse teste de carga demonstra o tempo de execução de procedures que começam do SP_ e
  com STP_. Esse ambiente não é totalmente compartilhado com outros processos em 
  execução. Por isso não temos concorrência e bloqueios. Em um ambiente produtivo como
  um grande ERP, esses valores podem ser maiores.

*/
use eCommerce
go

Create or Alter Procedure sp_HoraAtual 
as
begin
   declare @Data datetime 
   set @Data = GETDATE()
end 
go

Create or Alter Procedure stp_HoraAtual 
as
begin
   declare @Data datetime 
   set @Data = GETDATE()
end 
go


/*
Medição de Tempo
*/

set nocount on 
go
declare @dInicio datetime = getdate()
declare @p int = 0
while @p <=  1000000 begin 
   execute sp_HoraAtual
   set @p += 1
end
select DATEDIFF(MILLISECOND,@dInicio,getdate())


set nocount on 
go
declare @dInicio datetime = getdate()
declare @p int = 0
while @p <= 1000000 begin 
   execute stp_HoraAtual
   set @p += 1
end
select DATEDIFF(MILLISECOND,@dInicio,getdate())
go

/*
*/

use eCommerce
go
drop procedure sp_help
go




