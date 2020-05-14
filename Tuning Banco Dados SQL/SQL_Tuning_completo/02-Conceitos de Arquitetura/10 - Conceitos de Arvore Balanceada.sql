/*
Introdução

- Uma das técnicas mais eficientes para organizar dados para uma pesquisa rápida 
  é a utilização de ordenação utilizando uma estrutura de dados conhecida como árvore binária.

  - Essa estrutura é capaz de organizar os dados a partir de nó raiz com um único valor 
    (ou uma única chave) e com dois ponteiros refereciando os próximos nós.
  - Existe somente um nó raiz (root) onde começa a pesquisa.
  - Os nós intermediários onde se navega pela árvore
  - Nós folhas (leaf) onde eles não possuem referência para outro nós. 

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_bin%C3%A1ria

- Devido a algumas dificuldades em incluir, alterar ou excluir dados dentro dessa
  árvore, foi criando um estrutura semelhantes que é conhecidadae como b-tree.

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_B
  
- A diferença entre a árvore binária e a b-tree, é que a primeira é restrita a uma única
  chave de pesquisa em um determinado nó e tem dois ponteiros no máximo saindo de um nó.
  A segunda já permite um número maior de chaves em um nó e o número máximo de ponteiros
  saindo dó será de total de chaves mais 1.

- E temos uma outra variação da b-tree que é conhecido como b-tree+ (b-tree plus) que 
  entre suas características, a mais significativa é o encadeamento entre as nós folhas.

  Ref.: https://pt.wikipedia.org/wiki/%C3%81rvore_B%2B



*/

use DBDemo
go


Create or Alter View vRandData 
as
with cteRand as (
   select 1 as number , 0 as ancor
   union all
   select number+1 as number , 1 as ancor
   from cteRand
   where number < 1000
)
select number from cteRand 

select * from vRandData
option (maxrecursion 1000)


/*
Gerando 101 números aleátorios e sem ordem de apresentação.
Encontre o número 250
*/

select top 101 * 
  from vRandData
 order by newid()
option (maxrecursion 1000)



/*
Gerando 101 números aleátorios, ordenado de forma crescente.
Encontre o número 600
*/

select * from (
select top 101 * 
  from vRandData
 order by newid()
) as a order by 1
option (maxrecursion 1000)



/*
Gerando 11 números aleátorios, ordenado de forma crescente em uma B+Tree 
Encontre o número ???
*/

drop table if exists tNumber 
go

Create Table tNumber (id tinyint identity(1,1), Number smallint)
go

insert into tNumber (Number) 
select number from (
select top 11 * 
  from vRandData
 order by newid()
 ) as a order by number
option (maxrecursion 1000)

select * from tNumber order by number


select count(1) as TotalChaves from tNumber

-- Encontrar o número que representa a metada da lista

select * from tNumber where id = CEILING( 11/2.0)

select * from tNumber 


/*
Simulador de Arvore B+Tree 
Ref.: https://www.cs.usfca.edu/~galles/visualization/BPlusTree.html
*/





 
 
