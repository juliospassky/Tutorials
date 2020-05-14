use eCommerce
go

sp_helpindex2
sp_updatestats
Create Index idxDMovimento on tMovimento (dMovimento)
drop index idx_idCliente on tMOvimento


/*
*/
set nocount on 
go

Declare @cCPF char(14)
Declare @iidcliente int 
Select top 1 @iidcliente = iidcliente, @cCPF = cCPF from tCliente where iIDCliente = cast(rand()*200000 as int)
select top 1 * from tCliente where cCPF = @cCPF -- cast(rand()*71359198870    as bigint)
IF @cCPF is not null
   update tCliente set cCPF = cast(cast(@cCPF as bigint)+1 as char(14))
    where cCPF = @cCPF
    
if @iidcliente > 150000
insert into tSolicitaCredito (iIDCliente,dSolicitacao,mSolicitado,mAprovado,dAprovacao)
values (@iidcliente, getdate(), rand()*10000, rand()*10000,null)

/*
Produto 
*/
declare @iidproduto  int 
declare @cTitulo  varchar(100)
declare @cCodigo char(10) 
select top 1 @iidproduto  = iIDProduto  , @cCodigo = cCodigo from tProduto where iIDCategoria = cast(rand()*19 as int) order by NEWID()
if @iidproduto  > 50000
   update tProduto set cDescricao = replace(cDescricao,'a','a') where iidproduto = @iidproduto 
else 
   select top 1 @iidproduto  = iIDProduto  , @cTitulo  = cTitulo 
     from tProduto where cCodigo = @cCodigo and iIDCategoria = cast(rand()*19 as int) 
/*
Movimento 
*/
declare @dMovimentoi datetime = dateadd(d,-rand()*365,getdate())
declare @dMovimentfg datetime = dateadd(MINUTE,1,@dMovimentoi)
declare @iidmovimento int = 1
declare @mvalor money 

select @iidmovimento = iidmovimento , @mValor = mValor  from tMovimento with (index=idxDMovimento)
 where Dmovimento >= @dMovimentoi
  and  Dmovimento <= @dMovimentfg

/*
Item Movimento
*/
if @iidmovimento < 100000
   select top 1 1 from tItemMovimento
     join tMOvimento 
     on tItemMovimento.iIDMovimento = tMovimento.iIDMovimento
     where tItemMovimento.iIDMovimento = @iidmovimento
else 
   select nQuantidade from tItemMovimento where iIDMovimento = @iidmovimento

go 1000


select count(1) from tMovimento




