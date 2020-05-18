Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Tuning Banco de Dados
## Formatação do disco
Formatação NTFS ou ReFS, com unidades de alocação de 64K

## Criação do banco
Evite criar um banco com um simples comando: 
```sql
CREATE DATABASE MyDB
```

Esse modelo de criação Default não traz desempenho para o banco. Procure definir um tamanho inicial para o banco em MB ou GB, defina a taxa de crescimento (evite taxas de crescimento muito baixas) e procure separar os arquivos que compõe o banco para não sobrecarregar o arquivo mdf e se possível em mais de uma repartição de disco.
 
 
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
## Compactação de arquivos ( Diminui o número de páginas e melhora a performance de queries)
A compactação de arquivos ajuda a reduzir o espaço de armazenamento do banco e auxilia em queries.
É indicada em tabelas que possuem dados de tamanho curto, dados com tendência repetitiva e colunas com valores null

Pode-se verificar a eficiência da compactação através da query:
```sql
EXEC sp_estimate_data_compression_savings 'dbo', 'tCliente', null, NULL, 'PAGE' ;  
go

select total_pages , used_pages , data_pages  , p.data_compression_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
	where p.object_id = object_id('tCliente')
	  and au.type = 1
go
```

Sql para realizar a compressão do modo Page
```sql
ALTER TABLE dbo.tCliente
      REBUILD PARTITION = ALL  
	  WITH (DATA_COMPRESSION = PAGE)   
go
```
