
/*
Convertendo consultas NoSARG para SARG 
*/


/*
Exemplo 1 
*/
use eCommerce
go

sp_helpindex2 tMovimento 
go

Create Index idxDMovimento	on tMovimento (dMovimento,cStatus) on indicestransacionais 


set statistics io on 
go


-- NoSARG
Select iIDMovimento, cCodigo, nNumero,dMovimento
  From tMovimento
 Where DATEDIFF(d,dMovimento,'2018-05-18') < 2

-- SARG
Select iIDMovimento, cCodigo, nNumero,dMovimento
  From tMovimento
 Where dMovimento >= cast(DATEADD(dd,-1,'2018-05-18') as date)


/*
Exemplo 2 
*/

sp_helpindex2 tMovimento , @nOptions = 2


Declare @dDataInicio datetime = '2018-05-18'

-- NoSARG
Select iIDMovimento, dMovimento, cStatus 
  From tMovimento 
 Where DATEPART(MONTH,dMovimento) = DATEPART(MONTH,@dDataInicio)
   and DATEPART(YEAR,dMovimento) = DATEPART(YEAR,@dDataInicio)

-- SARG
Select iIDMovimento, dMovimento, cStatus 
  From tMovimento 
 Where dMovimento >= dateadd(day, -datepart(day,@dDataInicio)+1,@dDataInicio)
   and dMovimento < cast(dateadd(day,1,eomonth(@dDataInicio)) as datetime)


/*
Exemplo 3 
*/

sp_helpindex2 tCliente

-- NoSARG
Select cNome from tCliente
where left(cNome,8) = 'Wallace '
-- NoSARG
Select cNome from tCliente
where substring(cNome,1,8) = 'Wallace '

-- SARG
Select cNome from tCliente
where cNome like 'Wallace %'

/*
Exemplo 4 
*/

sp_helpindex2 tMovimento

 Create Index idxDataValidade 
     on tMovimento (dValidade,dMovimento) 
include (iidcliente) 
with (drop_existing = on )
     on indicestransacionais


declare @dData date = '2018-05-17'

Select dValidade , dMovimento, iIDCliente, iIDMovimento  
  from tMovimento 
where ISNULL(dValidade, @dData ) = @dData 
  and dMovimento >= '2018-04-17'
 
Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where (dValidade= @dData or dValidade is null)
  and dMovimento >= '2018-04-17'


Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where dValidade= @dData 
  and dMovimento >= '2018-04-17'
union all
Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where dValidade is null
  and dMovimento >= '2018-04-17'
