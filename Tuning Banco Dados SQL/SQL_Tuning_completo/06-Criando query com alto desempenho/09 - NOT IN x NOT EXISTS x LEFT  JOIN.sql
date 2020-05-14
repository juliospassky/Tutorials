/*
Quando utilizar NOT IN ou NOT EXISTS 

- Os operadores NOT INT e NOT EXISTS são operadores de negação que trabalham com um 
  subconjuntos de dados. 

- O operador lógico IN valida se a expressão informada está contida dentro de 
  de valores de uma subconsulta ou dentro de uma lista de valores.

  Where <expressão> IN (<subconsulta> ou <Lista de valores>)

- O operador lógico EXISTS valida se uma subconsulta tem a existências de linhas.

  Where EXISTS (<subconsulta>)

- O operador lógico IN avalia os três valores possíveis para testar a expressão: 

   - Verdadeiro, quando a expressão está contida nos valores da subconsulta ou
     válida para um item de uma lista.
   - Falso, quando a expressão não está contida nos valores da subsconsulta ou 
     inválida para um item de uma lista.
   - Desconhecido, quando o valor da expressão é válido (não nulo), não é encontrado
     na nova valores da subconsulta ou itens de uma lista e dentro  

- O operador lógico EXISTS avalida dois valores possíveis para testar a existência
  de uma linha da subconsulta:

   - Verdadeiro, se existe pelo menos uma linha dentro da subconsulta.
   - Falso, se não existe linhas dentro da subconsulta.

- Quando utilizamos o operador de negação NOT junto com IN e EXISTS.

   - No caso do operador EXISTS, o operador NOT negará os dois valores para testar 
     a expressão:

     - Verdadeiro, se não existe linhas dentro da subconsulta.
     - Falso, se existe pelo menos uma linha dentro da subconsulta.
     
   - No caso do operador IN, o operador NOT negará os valores para Verdadeiro ou Falso:

      - Falso, quando a expressão está contida nos valores da subconsulta ou
        válida para um item de uma lista.
      - Verdadeiro, quando a expressão não está contida nos valores da subsconsulta ou 
        inválida para um item de uma lista.

      - Quando existir dentro dos valores da subconsulta ou dentro de um item de uma lista 
        pelo menos um valor NULL, toda a expressão será validada como Desconhecida, 
        independente se o valor estiver contido na lista.

*/

use eCommerce
go

set statistics io on 

Select tCliente.iidcliente,
       tCliente.cNome 
  From tCliente
 Where tCliente.cUF = 'PB' and tCliente.cCidade = 'Jõao Pessoa'
   and tCliente.iIDCliente not in (Select iIDCliente 
                                     From tMovimento
                                  )
go
set statistics io off



set statistics io on 

Select tCliente.iidcliente,
       tCliente.cNome 
  From tCliente
 Where tCliente.cUF = 'PB' and tCliente.cCidade = 'Jõao Pessoa'
   and not exists (Select iIDCliente 
                     From tMovimento 
                    Where tMovimento.iIDCliente = tCliente.iIDCliente
                  )
go
set statistics io off




/*
NOT IN e NOT EXISTS, quando a coluna da subconsulta 
utilizada na expressão contém valor NULL.
-- Rodar o script 1 do arquivo 09a - Apoio NOT IN x NOT EXISTS.sql 

*/

use eCommerce
go

Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno = '00.002.47'

 Select cCodigoExterno 
  From tProduto
 Where cCodigoExterno = '00.002.47'


Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno not in (Select cCodigoExterno 
                                From tProduto 
                             )

Select cCodigoExterno 
  From tProdutoImportacao01
 Where not exists (Select cCodigoExterno 
                     From tProduto 
                    Where tProduto.cCodigoExterno = tProdutoImportacao01.cCodigoExterno
                  )



set statistics io on 
set nocount on 

Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno not in (Select cCodigoExterno 
                                From tProduto 
                               Where cCodigoExterno is not null)

Select cCodigoExterno 
  From tProdutoImportacao01
 Where not exists (Select cCodigoExterno 
                     From tProduto 
                    Where tProduto.cCodigoExterno = tProdutoImportacao01.cCodigoExterno)

set statistics io off

/*
Realizar o teste com o Client Statistics 
-- Reset Client Statistics 
-- Desativar o Plano de Execução 
-- Rodar o script 2 do arquivo 09a - Apoio NOT IN x NOT EXISTS.sql 
*/

set nocount on
set statistics io off

go
-- Trial 1 
Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno not in (Select cCodigoExterno 
                                From tProduto 
                               Where cCodigoExterno is not null)
go 1000

-- Trial 2                               
Select cCodigoExterno 
  From tProdutoImportacao01
 Where not exists (Select cCodigoExterno 
                     From tProduto 
                    Where tProduto.cCodigoExterno = tProdutoImportacao01.cCodigoExterno)
go 1000


/*
E o LEFT JOIN ???
*/


Select tProdutoImportacao01.cCodigoExterno 
  From tProdutoImportacao01
  Left Join tProduto 
  on tProdutoImportacao01.cCodigoExterno = tProduto.cCodigoExterno 
  where tProduto.iidProduto is null
go 1000