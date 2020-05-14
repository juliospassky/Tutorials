/*
- A aplicação de filtros de linhas utilizando expressões (SARG ou NoSARG) podem ser aplicadas
  no WHERE ou no HAVING.

- Considerando as fases de processamento lógico de uma querys, utilizamos uma regra básica que é:
   
   - Filtrar linhas no WHERE.

     Ele é utilizado após a fase FROM/JOIN onde recebe os dados processados pelas junções
     ou recuperado pelo FROM. São as linhas das tabelas sem qualquer tipo de transformação.

   - Filtrar grupos no HAVING.

     O HAVING é utiliza após e junto com o GROUP BY. Ele somente processa o resultado das linhas 
     agrupada e somente as colunas do GROUP BY ou as funções de agregações. Voce pode 
     user outras funções, mas desde que seja somente nas colunas do GROUP BY. 

*/

use eCommerce
go

sp_helpindex2 tMovimento , @nOptions = 2

go

drop Index idxEntrega on tMovimento 
go

Create Index idxEntregaRealizada on tMovimento (dEntregaRealizada) on IndicesTransacionais
go


/*
*/

-- DBCC FREEPROCCACHE

set statistics io on 

declare @dInicio datetime = '2018-05-17 00:00:00.00' 
declare @dFinal  datetime = '2018-05-18 00:00:00.00' 

Select dEntregaRealizada, 
       Count(1), 
       Sum(mvalor)
  From tMovimento
 Where dEntregaRealizada >= @dInicio
   and dEntregaRealizada < @dFinal
 Group by dEntregaRealizada
 option (recompile) 
 
Select dEntregaRealizada, 
       COUNT(1) as nQtd , 
       SUM(mValor) as mValor
  From tMovimento
 Group by dEntregaRealizada
Having dEntregaRealizada >= @dInicio
   and dEntregaRealizada < @dFinal
 option (recompile)  

set statistics io off




/*
Mas.... 
*/
go

declare @nAno int = 2018 
declare @nMes int = 5 

set statistics io on 

Select dEntregaRealizada, COUNT(1) as nQtd , SUM(mValor) as mValor
  From tMovimento
 Where YEAR(dEntregaRealizada) = @nAno
   and MONTH(dEntregaRealizada) = @nMes 
 Group by dEntregaRealizada
 option (recompile)


Select dEntregaRealizada, COUNT(1) as nQtd , SUM(mValor) as mValor
  From tMovimento
 Group by dEntregaRealizada
Having YEAR(dEntregaRealizada) = @nAno
   and MONTH(dEntregaRealizada) = @nMes 

set statistics io off



/*
O que deve ser filtrado no Having?

- Valores gerados na fase do GROUP BY que não existem nas fases anteriores.

O que deve ser filtrado no Where ?

- Valores que devem ser filtrados antes de serem agrupados.

*/
set nocount on


declare @dInicio datetime =  dateadd(d,rand()*-358,getdate())
declare @dfinal datetime  =  dateadd(d,1,@dInicio)
declare @dEntregaRealizada datetime
declare @nQuantidade int 

Select @dEntregaRealizada = dEntregaRealizada,@nQuantidade=COUNT(1) 
  From tMovimento
 Where dEntregaRealizada >= @dInicio
   and dEntregaRealizada < @dfinal
 Group by dEntregaRealizada
GO 100000

/*
Time Statistics			
  Client processing time	   7751		
  Total execution time	      82026		
  Wait time on server replies	74275		
*/

declare @dInicio datetime =  dateadd(d,rand()*-358,getdate())
declare @dfinal datetime  =  dateadd(d,1,@dInicio)
declare @dEntregaRealizada datetime
declare @nQuantidade int 

Select @dEntregaRealizada = dEntregaRealizada,@nQuantidade=COUNT(1) 
  From tMovimento
 Group by dEntregaRealizada
Having dEntregaRealizada >= @dInicio
   and dEntregaRealizada < @dfinal
go 100000

/*
Time Statistics					
  Client processing time	   8657		7751		8204.0000
  Total execution time	      75569		82026		78797.5000
  Wait time on server replies	66912		74275		70593.5000
*/

------------------
/*
Cenário onde temos duas expressões no filtro e um é obrigatoriamente
no Having. 
*/


declare @dInicio datetime = '2018-05-01' 
declare @dFinal datetime = '2018-05-28'

set statistics io on 

Select dEntregaRealizada, COUNT(1) 
  From tMovimento
 Where dEntregaRealizada >= @dInicio
   and dEntregaRealizada < @dFinal
 Group by dEntregaRealizada
 having  COUNT(1)  >= 260 


Select dEntregaRealizada, COUNT(1) 
  From tMovimento
 Group by dEntregaRealizada
Having dEntregaRealizada >= @dInicio
   and dEntregaRealizada < @dFinal
   and COUNT(1)  >= 260 

set statistics io off



