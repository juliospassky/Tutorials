Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Indexes

## Tipos de indexes
Mais usados:
-Clusterizado
-Não Clusterizado
-Exclusivo
-Indices com colunas incluídas
-Indices com colunas computadas
-Indices filtrados

Menos usados:
-Hash 
-Não clusterizado com otimização de memória.
-ColumnStore
-Espacial
-XML
-Indice para Full Text Search 

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
Clusterizado Único para manter essa restrição.
