Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Tuning Banco de Dados

## Ferramentas para medir queries
Pode se ativar ou desativar (on, off) as estatísticas da query com o comando:
```sql
set statistics io on
set statistics time on 

--Caso nao esteja em ambiente de produção recomenda-se limpar o fuffer e a cache
DBCC DROPCLEANBUFFERS 
DBCC FREEPROCCACHE 
```

Outra maneira é habilitar a ferramenta nativa do SSMS (Query -> Include Client Statistics) 