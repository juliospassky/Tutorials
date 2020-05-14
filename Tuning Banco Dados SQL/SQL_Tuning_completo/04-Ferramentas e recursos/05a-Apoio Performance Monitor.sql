/*
Demonstrando o consumo de database pages e page read/s para o objeto Buffer Manager
e o objeto Physical Disk temos o contador Avg Disk Queue Length 
*/


/*
Preparado do ambiente 
*/
use eCommerce
go

Drop Index if exists idciidcliente on tCliente 
Drop Index if exists idxNome on tCliente
Drop Index if exists idciIDMovimento on tMovimento
Drop Index if exists idx_idcliente on tMovimento
go

Create Clustered Index idciidcliente on tCliente (iidcliente)
Create Index idxNome on tCliente(iidcliente) include (cNome) 
Create Clustered Index idciIDMovimento on tMovimento(iidMovimento)
Create Index idx_idcliente on tMovimento(dMovimento,iidcliente) include (nNumero) 
go



/*
Inicio do teste 
*/
DBCC DROPCLEANBUFFERS 
go
checkpoint
go
waitfor delay '00:00:03'
go

declare @dinicio datetime  = dateadd(d, -cast(RAND()*365  as int), getdate())
declare @dfinal datetime  =  dateadd(d,1,@dinicio)

select @dinicio , @dFinal 

Select Mov.iIDMovimento, Mov.nNumero, Cli.cNome
  From tMovimento as Mov
  Join tCliente as Cli
    on Mov.iIDCliente = Cli.iIDCliente
 where Mov.dMovimento >= @dinicio 
   and Mov.dMovimento <= @dfinal
go 1000

DBCC DROPCLEANBUFFERS 
go

select COUNT(1) as  nPages from sys.dm_os_buffer_descriptors


-- Demonstração sem limpar o Buffer Cache. 

select * from tmovimento 


use eCommerce1
go

Create or Alter Procedure stp_RetornaProdutoAletaorio
as
begin
   Declare @iidProduto int 
   select top 1 @iidProduto = iidproduto from tItemMovimento order by NEWID()
   Return @iidProduto 
end 

go

/*
Monitora o Consumo de disco
*/

use eCommerce1
go

Declare @iidproduto int 
Execute  @iidproduto = stp_RetornaProdutoAletaorio


Select * 
  from tMovimento Mov 
  join tItemMovimento Item
    on Mov.iIDMovimento = Item.iIDMovimento
  join tProduto prd 
    on Item.iIDProduto = prd.iIDProduto
 where Item.iIDProduto = @iidproduto ;

WaitFor Delay '00:00:01' ;
go 20

checkpoint 
