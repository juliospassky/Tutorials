use eCommerce1
go

Create or Alter Procedure stp_RetornaProdutoAletaorio
as
begin
   Declare @iidProduto int 
   select top 1 @iidProduto = iidproduto from tProduto order by NEWID()
   Return @iidProduto 
end 

go

---------------
Declare @iidproduto int 
Execute  @iidproduto = stp_RetornaProdutoAletaorio

Checkpoint ;

DBCC DROPCLEANBUFFERS ;

Select top 1 * 
  from tMovimento Mov 
  join tItemMovimento Item
    on Mov.iIDMovimento = Item.iIDMovimento
 where Item.iIDProduto = @iidproduto ;

WaitFor Delay '00:00:00' ;
go 300