Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Indexes

## Tipos de indexes
Mais usados: Clusterizado; Não Clusterizado; Exclusivo; Indices com colunas incluídas; Indices com colunas computadas e
Indices filtrados.

Menos usados: Hash; Não clusterizado com otimização de memória; ColumnStore; Espacial; XML e Indice para Full Text Search 

## Clusterizado e Não Clusterizado
Limitações

Clusterizado: Apenas 1 índice pode ser criado na tabela.

Não Clusterizado: Vários índices podem ser criados na tabela.

"Quando cria-se um índices clusterizado, a tabela deixa de ser uma HEAP TABLE e passa a ser uma CLUSTERED TABLE
Em um índice Clusterizado, os dados da tabela são movidos para as páginas folhas e organizados de acordo com a chave do índice.
Podemos dizer que quando você pesquisa em um índice cluster, você está pesquisando na própria tabela."

Clusterizado
```sql
Create Clustered Index <Nome do Indice> on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 
```
Não Clusterizado
```sql
Create Index <Nome do Indice> on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 
```

Quando criamos em uma tabela uma constraint do tipo Primary Key, o SQL Server já cria um índice
Clusterizado Único para manter essa restrição.Ao criar uma chave primária o SQL já cria um índice clusterizado para a tabela.

Recomenda-se criar um índice (clusterizado ou não clusterizado) para as colunas da FK de outra tabela.
```sql
Create Index IDXFKProduto on tItemMovimento (iidproduto) 
```

## Index Composto

Em uma query que temos duas colunas que são utilizadas na expressao WHERE para realizar o filtro das linhas.
Podemos criar um índice que cobre as duas colunas e com isso acelarar a consulta.

Exemplo query composta por duas colunas:
```sql
Select * From tProduto 
 Where iIDCategoria = 8 and cCodigoExterno = '8712'
```

Exemplo de index composto para performar a query
```sql
Create Index idxCategoria on tProduto (iidCategoria, cCodigoExterno)
```

## Index Colunas Calculadas
Existe uma limitalção de 90 bytes para armazenar um index. 
Em alguns casos, é necessário criar uma coluna calculada para armazenar um index, por exemplo, um VARCHAR(MAX).
Nesse caso, recomenda-se utilizar uma função no SQL Server chamada BINARY_CHECKSUM() que gera um valor de soma de verificação de dados.

BINARY_CHECKSUM Ex.: 
```sql
Select BINARY_CHECKSUM('SQL SERVER 2017')

--Retorna o valor calculado 1985823776
```

Dessa forma, dado a coluna cDescricao VARCHAR(MAX), cria-se a coluna nCheckSumDescricao e o index 
```sql
Alter table tProduto add nCheckSumDescricao as binary_checksum(cDescricao) persisted
go

Create Index idxCheckSumDescricao on tProduto (nCheckSumDescricao)
go
```

Com isso a consulta a seguir evita um Table Scan e reduz consideravelmente o número de páginas pesquisadas
```sql
Declare @cDescricao varchar(max) 
Declare @nCheckSumDescricao int 

set @cDescricao = 'consectetuer, cursus et, magna. Praesent interdum ligula eu enim.'
set @nCheckSumDescricao = binary_checksum(@cDescricao)

Select * From tProduto Where cDescricao = @cDescricao 
    
Select * From tProduto Where nCheckSumDescricao = @nCheckSumDescricao
go
```
## Colunas incluídas e índice de cobertura
Colunas incluídas em um índice, é um recurso que permite incluír colunas na definição do índice e que não farão parte da chave.
Esse recurso existe para evitar o Key Lookup ou RID Lookup, a consulta carrega todos os dados que necessita apenas pesquisando no índice, sem a necessidade de acessar a tabela. 

```sql
Create NonClustered Index <Nome do Indice> on <Nome da tabela> (<Coluna1>,<Coluna2>,...) 
    Include ((<Coluna3>,<Coluna4>,...)
```

## Mantenção de Index
A manutenção de Index é necessária para otimizar os processos de busca nas tabelas. Recomenda-se atualizar as estátisticas do index e fazer rebuild periodicamente.

A divisão de uma página (page split) ocorre em operações INSERT e UPDATE quando ocorre uma tentativa de alocar um nova linha na página e não existe mais espaço. O SQL Server cria uma nova página, transfere metade dos dados entre essas duas páginas, realiza a operação (INSERT ou UPDATE) e atualiza os ponteiros das páginas. Observação: o processo só ocorre em tabelas e índices já criados.

Um processo manual para fazer um rebuild do index pode envolver um parâmetro (FillFactor) que varia em porcentagem de 1 a 100. Esse valor vai decidir o tamanho do pagesplit. Nota-se que esse processo pode aumentar o número de páginas e consequentemente reduzir a eficiência da query.

Rebuild do index com FillFactor
```sql
Alter Index idcDemo on tDemoPageSplit Rebuild with (fillfactor = 75)
```
