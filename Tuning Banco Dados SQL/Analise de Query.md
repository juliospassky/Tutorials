Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Ferramentas para medir e analisar queries

## Ativar ou desativar (on, off) as estatísticas da query
```sql
set statistics io on
set statistics time on 

--Caso nao esteja em ambiente de produção recomenda-se limpar o fuffer e a cache
DBCC DROPCLEANBUFFERS 
DBCC FREEPROCCACHE 
```

## Habilitar a ferramenta nativa do SSMS
(Query -> Include Client Statistics) 

## (Profile) Ferramenta para monitorar eventos no SSMS 
Cuidado: Essa ferramenta é custosa para o banco
No SSMS Tools -> SQL Server Profile

Eventos:
- Execuções de comandos SELECT, INSERT, UPDATE e DELETE
- Conexões, desconexões e falhas
- Bloqueios criados e liberados
- Aumento e Redução do banco de dados
- Mensagens de erros e avisos

Dica, nas opções de escolha do profile, ative T-SQL -> SQL:StmtCompleted (Indica que uma instrução Transact-SQL foi concluída), utiliza o filtro com o valor do SPID (Id da tela atual de query no SSMS (select @@SPID)

## Plano de execução estimado e real
Para ativar o estimado (antes de realizar a query) Ctrl + L ou no menu do SSMS clique no botão (Display Extimated Execution Plan)
Para ativar o real (após de realizar a query) Ctrl + M ou no menu do SSMS clique no botão (Include Actual Execution Plan)

Devemos evitar os operadores:
- Table Scan (Tabela sem index - Varre toda a tabela)
- Index Scan (Varre toda a tabela)
- Sort (Ordenar os dados sem necessidade real)
- RID Lookup (Heap - RID busca dados que são pedidos na query mas não possuem index)
- Compute Scalar (Operação matemática na consulta)

