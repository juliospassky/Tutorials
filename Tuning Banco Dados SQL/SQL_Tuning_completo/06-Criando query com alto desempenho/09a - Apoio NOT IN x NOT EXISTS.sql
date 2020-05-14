use eCommerce
go

/*
Script 1 
*/
Drop table if exists tProdutoImportacao01 
go

Create Table tProdutoImportacao01 (
	cTitulo varchar(120) NOT NULL,
	cDescricao varchar(max) NOT NULL,
	nPreco smallmoney NOT NULL,
	cCodigoExterno varchar(20) NULL,
) on DADOSTRANSACIONAIS ;
go

Insert into tProdutoImportacao01
Select top 1000 cTitulo,cDescricao, nPreco * 1.12 , replace(cCodigoExterno,'9','0')
  From  tProduto
  where cCodigoExterno like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
  order by newid()
go
Create Clustered Index idcCodigoExterno on tProdutoImportacao01 (cCodigoExterno) 
go



/*
Script 2 
*/
use eCommerce
go

begin transaction 
delete tProdutoImportacao01

Insert into tProdutoImportacao01
Select top 1000 cTitulo,cDescricao, nPreco * 1.12 , replace(cCodigoExterno,'9','0')
  From  tProduto
  where cCodigoExterno like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
  order by newid()

commit 
waitfor delay '00:00:00.1'
go 1000
