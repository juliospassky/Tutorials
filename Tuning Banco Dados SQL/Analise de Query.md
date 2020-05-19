Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Tuning Banco de Dados

## Ferramentas para medir queries
1) Pode se ativar ou desativar (on, off) as estatísticas da query com o comando:
```sql
set statistics io on
set statistics time on 

--Caso nao esteja em ambiente de produção recomenda-se limpar o fuffer e a cache
DBCC DROPCLEANBUFFERS 
DBCC FREEPROCCACHE 
```

2) Outra maneira é habilitar a ferramenta nativa do SSMS (Query -> Include Client Statistics) 

## (Profile) Ferramenta para monitorar eventos no SSMS 
No SSMS Tools -> SQL Server Profile

Eventos:
- Execuções de comandos SELECT, INSERT, UPDATE e DELETE
- Conexões, desconexões e falhas
- Bloqueios criados e liberados
- Aumento e Redução do banco de dados
- Mensagens de erros e avisos

Dica, nas opções de escolha do profile, ative T-SQL -> SQL:StmtCompleted (Indica que uma instrução Transact-SQL foi concluída)
