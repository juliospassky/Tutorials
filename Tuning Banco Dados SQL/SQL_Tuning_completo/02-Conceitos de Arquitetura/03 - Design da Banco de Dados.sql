/*
Banco de dados..

- Definição clássica: Um banco de dados é uma coleção de tabelas estruturadas que 
  armazena um conjunto de dados.......

- O que interessa para esse treinamento: Os dados as aplicações ficam armazenados em 
  arquivos em disco. 

- Cada banco de dados no SQL Server tem no mínimo dois arquivos. Uma arquivo de dados
  conhecido como arquivo Primário e tem a extensão MDF e outro arquivo de log 
  com a extensão LDF para registrar os log de transção (vamos tratar somente de
  arquivo de dados neste treinamento). 

*/
Drop Database if exists DBTeste
go

Create Database DBTeste
go

Use DBTeste
go

select * from sys.database_files

/*
- Cada arquivo tem um FILE ID que é o número de identificação do arquivo. Importante.
- A coluna DATA_SPACE_ID é a identificação desse arquivo dentro um grupo de arquivo. 
- A coluna NAME é o nome lógico do arquivo
- A coluna SIZE é o tamanho alocado do arquivo em páginas de dados
- A coluna GROWTH é a taxa de crescimento do arquivo em bytes
*/

/*

- No arquivo Primário ou MDF além de termos os dados da aplicação, temos também as 
  informações sobre :

  - Inicialização do banco de dados;
  - A referência para outros arquivos de dados do banco;
  - Metadados de todos os objetos de banco de dados criados pelos desenvolvedores.

  Todo e qualquer comando que tenha alguma referência a objetos como tabela, colunas, view, etc.,
  sempre consulta os metadados desses objetos no arquivo primário.

  Um simples SELECT Coluna FROM Tabela, faz com que o SQL Server consulte nos metadados se a COLUNA
  existe e se a TABELA existe também. 
  
- Existe um outro tipo de arquivo que podemos (e devemos) associar ao banco de dados que é conhecido 
  como Secundário de dados. Ele tem a extensão NDF.

  Cada arquivo de dados deve possuir algumas características como :

      - Será agrupado junto com outros arquivos de dados em um grupo lógico chamado
        de FILEGROUP (FG). Se não especificado o FG, o arquivo fica no grupo de arquivo PRIMARY.

      - Deve ter um nome lógico que será utilizado em instruções T-SQL;

      - Deve ter um nome físico onde consta o local o arquivo no sistema operacional;

      - Dever ter um tamanho inicial para atender a carga de dados atual e uma previsão
        futura;

      - Deve ter uma taxa de crescimento definida. Ela será utiliza para aumentar o 
        tamanho do arquivo de dados quando o mesmo estiver cheio;

      - Deve ter um limite máximo de crescimento. Isso é importante para evitar 
        que arquivos crescem é ocupem todo o espaço em disco.

Exemplos de criação de banco de dados :

*/
Drop Database if exists DBDemo_01
go

CREATE DATABASE DBDemo_01
GO

USE DBDemo_01
GO

Select size*8 as TamanhoKb , growth as CrescimentoKB , *  
  From sys.database_files

use Master
go

DROP DATABASE DBDemo_01
GO

/*

*/
DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA                      -- Instrução par criar o banco de dados.
ON PRIMARY                                   -- FG PRIMARY. 
 ( NAME = 'Primario',                        -- Nome lógico do arquivo.
   FILENAME = 'D:\DBDemoA_Primario.mdf' ,    -- Nome físico do arquivo.
   SIZE = 256MB                              -- Tamanho inicial do arquivo.
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

use DBDemoA
go

Select size*8 as TamanhoKb , growth  as CrescimentoKB , *  from sys.database_files
go

/*
Criando com 2 arquivos de dados 
*/

Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 256MB 
 ),                                             -- Segundo Arquivo de dados, no mesmo FG
 ( NAME = 'Secundario',                         
   FILENAME = 'E:\DBDemoA_Secundario.ndf' , 
   SIZE = 256MB 
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

/*
   No exemplo acima, temos dois arquivos de dados no FG PRIMARY. Os dados gravados
   nesse grupo serão distribuidos de forma proporcional dentro dos arquivos.
*/

use DBDemoA
go

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.database_files

/*

FILEGROUP
---------

- FILEGROUP é um agrupamento lógico de arquivos de dados para distribuir melhor a 
  alocação de dados entre os discos, agrupar dados de acordo com contextos ou 
  arquivamentos como também permitir ao DBA uma melhor forma de administração.

  No nosso caso, vamos focar em melhorar o desempenho das consultas.
      
*/

Use Master
go

DROP DATABASE if exists DBDemoA
GO

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

/*
Estamos dizendo para o SQL SERVER onde ele deve gravar todos os dados da 
aplicação. 
*/
ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT 
GO



USE DBDemoA
GO

Select size*8 as TamanhoKb , growth as CrescimentoKB , *  from sys.database_files
go

Select * from sys.filegroups
go 


/*
*/

select * from sys.dm_db_file_space_usage

/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-file-space-usage-transact-sql
*/


Use Master
go

DROP DATABASE if exists DBDemoA
GO



CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 512MB ,
   MAXSIZE = 512MB  
 ), 
FILEGROUP DADOS
 ( NAME = 'DadosTransacional1', 
   FILENAME = 'd:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  

 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'd:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  
 ) ,
 FILEGROUP INDICES 
 ( NAME = 'IndicesTransacionais1', 
   FILENAME = 'E:\DBDemoA_SecundarioI1.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  
 ) ,
 ( NAME = 'IndicesTransacionais2', 
   FILENAME = 'E:\DBDemoA_SecundarioI2.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 10GB  
 ),
 FILEGROUP DADOSHISTORICO
 ( NAME = 'DadosHistorico1', 
   FILENAME = 'E:\DBDemoA_SecundarioH1.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 20GB  
 ) ,
 ( NAME = 'DadosHistorico2', 
   FILENAME = 'E:\DBDemoA_SecundarioH2.ndf' , 
   SIZE = 1024MB,
   MAXSIZE = 20GB  
 ) 

LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO
go
ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT 
GO

/*
Analisando o Banco
*/

use DBDemoA
go

Select size*8 as TamanhoKb , growth  as CrescimentoKB , *  from sys.database_files
go
Select * from sys.filegroups
go 

select * from sys.dm_db_file_space_usage
