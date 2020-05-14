Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Criação do banco
Evite criar um banco com um simples comando: 
```sql
CREATE DATABASE MyDB
```

Esse modelo de criação Default não traz desempenho para o banco. Procure definir um tamanho inicial para o banco em MB ou GB, defina a taxa de crescimento (evite taxas de crescimento muito baixas) e procure separar os arquivos que compe o banco para não sobrecarregar o arquivo mdf

 
Exemplo de criação:
```sql
CREATE DATABASE DBDemoA
ON PRIMARY                                      -- FG Primario 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 64MB 
 ), 
FILEGROUP DADOS                                 -- FG com o nome DADOS 
 ( NAME = 'DadosTransacional1',                 
   FILENAME = 'E:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'E:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )   
GO

/* Estamos dizendo para o SQL SERVER onde ele deve gravar todos os dados da aplicação. */
ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT 
GO
```
