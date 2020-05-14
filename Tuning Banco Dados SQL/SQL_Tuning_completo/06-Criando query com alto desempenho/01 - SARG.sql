use eCommerce
go

/*
- SARG é a redução de Search Argument ou Argumento de Pesquisa. 

- SARG é um conceito que, aplicado nas nossas querys, restringe uma 
  busca porque especifica uma correspodência exata, um intervalo 
  de valores ou um conjunto de duas ou mais expressões unidas 
  pelo operador 'AND'.

- Uma expressão SARG é avalida pelo Otimizador de consulta que consegue 
  interpretar o seu conteúdo e com base nesse conteúdo, tenta escolher o 
  melhor índice para fazer essa pesquisa.

- Considerando que uma expressão SARG pode ser utiliza na cláusula WHERE ou HAVING para filtro de linhas 
  ou em cláusula ON de um JOIN, ela é composta por :
   
   - <Coluna> <Operador> <Valor> 

     Onde: 
      <Coluna>   - Nome da coluna que será pesquisada. 
                   Não deve existir mais nada além do nome da coluna. Enfim, ele deve ficar sozinha.
      <Operador> - Operador de comparação considerados inclusivos : São eles 
                   = 
                   >
                   <
                   >=
                   <=
                   Between
                   Like ( é somente um caso).
      <Valor>    - Expressão constante, do mesmo tipo da coluna. Pode ser uma váriavel.             


- Fora da regra acima, a pesquisa é considerada NoSARG.
  
*/

Create Index idxCadastro on tCliente(dCadastro) on IndicesTransacionais 
Create Index idxNome on tCliente(cNome) on IndicesTransacionais 
Create Index idxCodigoExterno  on tProduto (cCodigoExterno) on IndicesTransacionais 
Create Index idxStatus on tMovimento (dCancelamento ) include(cTipo)  with (drop_existing=on) on IndicesTransacionais 
Create Index idxStatus1 on tMovimento (cStatus) include (cTipo) on IndicesTransacionais



/*
Exemplos de pesquisas SARG 
*/

set statistics io on 

Select iidCategoria , cCodigo , cTitulo 
  From tProduto 
 Where iidproduto = 1
go

Select * From tProduto
where cCodigoExterno like '86%'


Select iidCliente, cNome, cCPF, dCadastro 
  From tCliente 
 Where dCadastro > '2018-01-01'
go

Select iidMovimento,iidCliente, cCodigo, nNUmero, dMovimento  
  From tMovimento 
 where dMovimento >= '2018-05-15' 
   and dMovimento <= '2018-05-16'

go

Select iIDCliente, cNome, cCPF  from tCliente 
Where cNome = 'Mason M. Moore'

go


Select iIDCliente, cNome, cCPF  from tCliente 
Where cNome like 'Wallace%'


Select * 
  from tMovimento Mov
  join tItemMovimento Item
  on Mov.iIDMovimento = Item.iIDMovimento 
where dMovimento >= '2018-05-18' and cTipo = 'PD'


/*
Exemplo de pesquisas NoSARG 
*/

sp_helpindex tProduto

Set statistics io on 

Select iidCategoria , cCodigo , cTitulo 
  From tProduto 
 Where iidproduto = 1
go

Select iidCategoria , cCodigo , cTitulo 
  From tProduto 
 Where iidproduto * 1 = 1
go


Select iidCliente, cNome, cCPF, dCadastro 
  From tCliente 
 Where cast(dCadastro as datetime) > '2018-01-01'
go


Select * From tProduto
where substring(cCodigoExterno, 1,2) = '86'


Select iidMovimento,iidCliente, cCodigo, nNUmero, dMovimento  
  From tMovimento 
 Where YEAR(dMovimento) = 2018 
   and MONTH(dMovimento) = 5 
   and DAY(dMovimento)= 15


Select iidMovimento,iidCliente, cCodigo, nNUmero, dMovimento  
  From tMovimento 
 Where CAST(dMovimento as date) = '2018-05-15'

Select iIDCliente, cNome, cCPF  from tCliente 
Where upper(cNome) = 'MASON M. MOORE'


Select * 
  from tMovimento Mov
  join tItemMovimento Item
  on cast(Mov.iIDMovimento as bigint) = cast(Item.iIDMovimento as bigint) 
where dMovimento >= '2018-05-18' and cTipo = 'PD'


Set statistics io off






