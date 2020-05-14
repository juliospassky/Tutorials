use eCommerce
go

Drop table if exists tProdutoImportacao01; 
go

Create Table tProdutoImportacao01 (
	cTitulo nvarchar(120) NOT NULL,
	cDescricao nvarchar(max) NOT NULL,
	nPreco numeric(18,4) NOT NULL,
	cCodigoExterno nvarchar(10) NULL,
) on DADOSTRANSACIONAIS ;
go
Insert into tProdutoImportacao01
Select top 100 cTitulo,cDescricao, nPreco * 1.12 , cCodigoExterno 
  From  tProduto
  where cCodigoExterno like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
go
Create Clustered Index idcCodigoExterno on tProdutoImportacao01 (cCodigoExterno) 
go


/*
*/

Drop table if exists tProdutoImportacao02; 
go

Create Table tProdutoImportacao02 (
	cTitulo nvarchar(120) NOT NULL,
	cDescricao nvarchar(max) NOT NULL,
	nPreco numeric(18,4) NOT NULL,
	cCodigoExterno varchar(20) NULL,
) on DADOSTRANSACIONAIS ;
go
Insert into tProdutoImportacao02 
Select top 100 cTitulo,cDescricao, nPreco * 1.12 , cCodigoExterno 
  From  tProduto
 where cCodigoExterno like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
go
Create Clustered Index idcCodigoExterno on tProdutoImportacao02 (cCodigoExterno) 
go



