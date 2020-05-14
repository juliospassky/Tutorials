Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Criação do banco
Evite criar um banco com um simples comando: 
```sql
CREATE DATABASE MyDB
```

Esse modelo de criação Default não traz desempenho para o banco. Procure definir um tamanho inicial para o banco em MB ou GB, defina a taxa de crescimento (evite taxas de crescimento muito baixas) e procure separar os arquivos que compe o banco para não sobrecarregar o arquivo mdf e se possível em mais de uma repartição de disco.
 
 
Exemplo de criação:
```sql
CREATE DATABASE MyDB
ON PRIMARY ( NAME = 'Primario', FILENAME = 'D:\MyDB_Primario.mdf', SIZE = 64MB), -- FG Primario
FILEGROUP DADOS ( NAME = 'DadosTransacional1', FILENAME = 'E:\MyDB_SecundarioT1.ndf',SIZE = 1024MB),
 ( NAME = 'DadosTransacional2', FILENAME = 'E:\MyDB_SecundarioT2.ndf', SIZE = 1024MB) -- FG com o nome DADOS 
LOG ON ( NAME = 'Log', FILENAME = 'F:\MyDB_Log.ldf',SIZE = 512MB)   
GO

/* Estamos dizendo para o SQL SERVER onde ele deve gravar todos os dados da aplicação. */
ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT 
GO
```
