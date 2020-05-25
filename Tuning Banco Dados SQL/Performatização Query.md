Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Performatização de Queries
## Search Argument (SARG)
SARG é a forma correta de montar a query para performar a consulta.

Deve-se montar a estrutura < Coluna > < Operador > < Valor >. A < Coluna > da clausula não deve conter operação.

Exemplo SARG e NoSARG, ambas trazem o mesmo resultado, no entanto a SARG é a performática
```sql

--Exemplo 1
--SARG
Select iidCliente, cNome, cCPF, dCadastro From tCliente 
 Where dCadastro > '2018-01-01'

--NoSARG
Select iidCliente, cNome, cCPF, dCadastro From tCliente 
 Where cast(dCadastro as datetime) > '2018-01-01'

--Exemplo 2
--SARG
Select iIDCliente, cNome, cCPF  from tCliente 
Where cNome like 'Wallace%'

--NoSARG
Select iIDCliente, cNome, cCPF  from tCliente 
Where  substring(cNome, 1,7) = 'Wallace'
```
