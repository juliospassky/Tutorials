/*

Todos os dados enviados das aplicações e sistemas para um banco de dados
são gravados em tabelas. 

Os dados são enviados para as instruções INSERT e UPDATE para manutenção ou
DELETE para excluir os dados.

As tabelas tem uma outra definição interna que são chamados de objetos
de alocação de dados. 

Esses objetos de alocação são gravados dentro dos arquivos de dados 
(localizados em discos) e associados a um banco de dados. 

Em cada arquivo de dados, temos áreas pré-definidas onde os dados são gravados. Essas 
áreas são associadas aos objetos de alocação e onde os dados são gravados em formado de 
registro de dados. 

Essas áreas são conhecidas como PÁGINAS DE DADOS.

- Uma página de dados é a menor alocação de dados utilizada pelo SQL Server. 
  Ela é a unidade fundamental de armazenamento de dados. 

- Uma página de dados tem um tamanho definido de 8Kbytes ou  8192 bytes que são
  dividos entre cabeçalho, área de dados e slot de controle (maiores detalhes 
  discutiremos na seção Armazenamento de dados).

- Uma página de dados é exclusiva para um objeto de alocação e um objeto de alocação
  pode ter diversas páginas de dados. 

- Em uma página de dados somente serão armanzendos 8060 bytes de dados em cada linha. 
  
PÁGINA DE DADOS - 8Kb ou 8192 bytes 

+-------+           +------------+
|       |           |            |      
|  8Kb  |    -->>   | 8060 bytes |
|       |           |            | 
+-------+           +------------+

Exemplos que demonstram a existência de páginas de dados

*/

use Master
go 

Drop Database if exists DBDemo
go

Create Database DBDemo
go

Use DBDemo 
go

Select DB_name(), DB_id()

go
/*
Primeiro Teste 

Tabela Teste01

- Três colunas de tamanho fixo com 4Kbytes em cada coluna.

*/

Create Table Teste01 
(
   cDescricao char(4096),
   cTitulo char(4096),
   cObservacao char(4096)
)

/*
Msg 1701, Level 16, State 1, Line 69
Creating or altering table 'Teste01' failed because the minimum row size would be 12295, 
including 7 bytes of internal overhead. 
This exceeds the maximum allowable table row size of 8060 bytes.

*/

go 

Create Table Teste01 
(
   cDescricao char(4000),
   cTitulo char(4000)
)
go

insert into Teste01 (cDescricao,cTitulo) values('Minha descricao', 'Meu titulo')
go

select * from Teste01

execute sp_spaceused 'Teste01' 

insert into Teste01 (cDescricao,cTitulo) values('Minha descricao', 'Meu titulo')
go

execute sp_spaceused 'Teste01' 



/*
sp_spaceused
Ref. https://docs.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-spaceused-transact-sql
*/



/*
------------------------------------------------------
Extent ou Extensão. 

- São agrupamentos lógicos de páginas de dados.  

- Seu objetivo é gerenciar melhor o espaço alocado do dados. 

- Um Extent tem exatamente 8 páginas de dados e um tamanho de 64 Kbytes. 

+------------------------------------------------------------------------------------------+
|                                           64 Kb                                          |
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  |
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  | 
|  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  | 
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  | 
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  | 
+------------------------------------------------------------------------------------------+

- Extents podem ser
   - Misto (Mixed Extent), quando as páginas de dados são de objetos de alocãções
     diferentes.

   - Uniforme (Uniform Extent), quando as páginas de dados são exclusiva de um único objeto
     de alocação 


Mixed Extent 
+------------------------------------------------------------------------------------------+
|                                           64 Kb                                          |
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  |
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |      
|  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  | 
|  |  A    |  |   B   |  |   B   |  |   A   |  |   A   |  |   B   |  |   B   |  |   C   |  | 
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  | 
+------------------------------------------------------------------------------------------+


Uniform Extent.
+------------------------------------------------------------------------------------------+
|                                           64 Kb                                          |
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  |
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |      
|  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  | 
|  |  A    |  |   A   |  |   A   |  |   A   |  |   A   |  |   A   |  |   A   |  |   A   |  | 
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  | 
+------------------------------------------------------------------------------------------+

- Uma nova tabela é alocada em um Mixed Extent utilizando um página de dados. Se a tabela precisa 
  de uma nova página e o Extent tem paginas não utilizadas, o SQL Server continua a alocar 
  os dados no Mixed Extent, junto com páginas de dados de outros objetos de alocação.

- Se a precisar de mais uma página de dados e não tem mais páginas de dados no Mixed Extent, 
  então o SQL SERVER começa a alocar todas as novas páginas em Uniform Extent.




