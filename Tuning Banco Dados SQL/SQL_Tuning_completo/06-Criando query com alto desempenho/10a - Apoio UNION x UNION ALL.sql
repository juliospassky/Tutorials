use eCommerce
go

drop Index if exists PKEmpresa on tEmpresa 
drop Index if exists idxCidadeUF on tEmpresa
go

Create Unique Clustered Index PKEmpresa on tEmpresa (iidEmpresa) on DADOSTRANSACIONAIS
Create Index idxCidadeUF on tEmpresa (cCidade,cUF) on INDICESTRANSACIONAIS


Drop table if exists tProdutoImportacao03; 
go

Create Table tProdutoImportacao03 (
	cTitulo nvarchar(120) NOT NULL,
	cDescricao nvarchar(max) NOT NULL,
	nPreco numeric(18,4) NOT NULL,
	cCodigoExterno nvarchar(10) NULL,
   nEstoque numeric(10) NULL 
) on DADOSTRANSACIONAIS ;
go

Insert into tProdutoImportacao03
Select top 50 cTitulo,cDescricao, nPreco * 1.12 , 'X'+SUBSTRING(cCodigoExterno,2,100) ,nEstoque 
  From  tProduto
  where cCodigoExterno like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
  order by NEWID()

Insert into tProdutoImportacao03
Select top 50 cTitulo,cDescricao, nPreco * 1.12 , cCodigoExterno , nEstoque
  From  tProduto
  where cCodigoExterno NOT like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
  order by NEWID()


go
Create Clustered Index idcCodigoExterno on tProdutoImportacao03 (cCodigoExterno) 
go



Drop table if exists tProdutoImportacao04; 
go

Create Table tProdutoImportacao04 (
	cTitulo varchar(120) NOT NULL,
	cDescricao varchar(max) NOT NULL,
	nPreco smallmoney NOT NULL,
	cCodigoExterno varchar(20) NULL,
   nEstoque int NULL 
) on DADOSTRANSACIONAIS ;
go

Insert into tProdutoImportacao04
Select top 50 cTitulo,cDescricao, nPreco * 1.12 , 'X'+SUBSTRING(cCodigoExterno,2,100) ,nEstoque 
  From  tProduto
  where cCodigoExterno like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
  order by NEWID()

Insert into tProdutoImportacao04
Select top 50 cTitulo,cDescricao, nPreco , cCodigoExterno , nEstoque
  From  tProduto
  where cCodigoExterno NOT like '[0-9][0-9].[0-9][0-9][0-9].[0-9][0-9]'
  order by newid()


go
Create Clustered Index idcCodigoExterno on tProdutoImportacao04 (cCodigoExterno) 
go


/*
*/




