/*
Demonstração de armazenando de CHAR vs. VARCHAR ou 
comparação dentre armazenar dados fixo vs variável 
*/

 --- Tamanho fixo 
 use DBDemo
 go

 drop table if exists DemoChar
 go

 Create Table DemoChar (
   Id int ,              -- Fixo de 4 bytes 
   Titulo char(4000) ,   -- Fixo de 4000 bytes 
   Descricao char(4000)  -- Fixo de 4000 bytes 
 )
 go

 
/*
+---------+---------+---------+--------+---------+---------+----------+
| 4 bytes | 8004 by | 2 bytes | 1 byte | 2 bytes | n bytes | n bytes  |
| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável |  
+---------+---------+---------+--------+---------+---------+----------+

Qual será o tamanho da linha ?
+---------+---------+---------+--------+
| 4 bytes | 8004 by | 2 bytes | 1 byte |  
| Header  | Fixo    | QtdCol  | NullMap|
+---------+---------+---------+--------+
Adicionando 2 bytes da matriz de Slots, temos 8013 bytes

Quantas linhas por página? 

*/

insert into DemoChar (id,Titulo,Descricao) values (1,replicate('A',4000), replicate('a',4000))
insert into DemoChar (id,Titulo,Descricao) values (1,replicate('A',4000), replicate('a',4000))
insert into DemoChar (id,Titulo,Descricao) values (1,replicate('A',4000), replicate('a',4000))
 
select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from DemoChar as tab

insert into DemoChar (id,Titulo,Descricao) values (1,'B','b')
insert into DemoChar (id,Titulo,Descricao) values (1,'B','b')
insert into DemoChar (id,Titulo,Descricao) values (1,'B','b')

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from DemoChar as tab



 
 --- Tamanho Variável 
 use DBDemo
 go

 drop table if exists DemoVarChar
 go

 Create Table DemoVarChar (
   id int , 
   Titulo varchar(4000), 
   Descricao varchar(4000)
 )
go

/*
Qual será o tamanho da linha ? 

Depende dos dados variáveis.

+---------+---------+---------+--------+---------+---------+----------+
| 4 bytes | 4 bytes | 2 bytes | 1 byte | 2 bytes | 4 bytes | n bytes  |  17 + n 
| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável |  
+---------+---------+---------+--------+---------+---------+----------+

Adicionando 2 bytes da matriz de Slots, temos : 19 + N !!!

onde n será o total de bytes das colunas variáveis. 



Considerando a capacidade máxima das colunas variáveis:
+---------+---------+---------+--------+---------+---------+-------------+
| 4 bytes | 4 bytes | 2 bytes | 1 byte | 2 bytes | 4 bytes | 8000 bytes  |  8019 bytes
| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável    |  
+---------+---------+---------+--------+---------+---------+-------------+

Quantas linhas por página? 

8019 bytes por linha --> 8096 / 8019 = 1,009 --> 1 linha por Página.
*/

insert into DemoVarChar (id,Titulo,Descricao) values (1, replicate('A',4000), replicate('a',4000))
insert into DemoVarChar (id,Titulo,Descricao) values (1, replicate('A',4000), replicate('a',4000))

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from DemoVarChar as tab
  where id = 1 

/*
Considerando a metada da capacidade máxima das colunas variáveis:
+---------+---------+---------+--------+---------+---------+-------------+
| 4 bytes | 4 bytes | 2 bytes | 1 byte | 2 bytes | 4 bytes | 4000 bytes  |  4019 bytes
| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável    |  
+---------+---------+---------+--------+---------+---------+-------------+

4019 bytes por linha --> 8096 / 4017 = 2,015 --> 2 linhas por Página.

*/
Truncate table DemoVarChar 
go
insert into DemoVarChar (id,Titulo,Descricao) values (2,replicate('B',2000), replicate('b',2000))
insert into DemoVarChar (id,Titulo,Descricao) values (2,replicate('B',2000), replicate('b',2000))
insert into DemoVarChar (id,Titulo,Descricao) values (2,replicate('B',2000), replicate('b',2000))
insert into DemoVarChar (id,Titulo,Descricao) values (2,replicate('B',2000), replicate('b',2000))

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from DemoVarChar as tab
  where id = 2 


/*
Considerando a 1000 bytes para cada coluna variável:
+---------+---------+---------+--------+---------+---------+-------------+
| 4 bytes | 4 bytes | 2 bytes | 1 byte | 2 bytes | 4 bytes | 2000 bytes  |  2019 bytes
| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável    |  
+---------+---------+---------+--------+---------+---------+-------------+

2019 bytes por linha --> 8096 / 2019 = 4,009 --> 4 linhas por Página.

*/
Truncate table DemoVarChar 
go

insert into DemoVarChar (id,Titulo,Descricao) values (3,replicate('C',1000), replicate('c',1000))
insert into DemoVarChar (id,Titulo,Descricao) values (3,replicate('C',1000), replicate('c',1000))
insert into DemoVarChar (id,Titulo,Descricao) values (3,replicate('C',1000), replicate('c',1000))
insert into DemoVarChar (id,Titulo,Descricao) values (3,replicate('C',1000), replicate('c',1000))

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from DemoVarChar as tab
  where id = 3 

dbcc traceon(3604)
go
declare @dbid int = db_id()
dbcc page(@dbid, 1, 144, 1) 


/*
Considerando a 100 bytes para cada coluna variável:
+---------+---------+---------+--------+---------+---------+-------------+
| 4 bytes | 4 bytes | 2 bytes | 1 byte | 2 bytes | 4 bytes | 200 bytes   |  219 bytes
| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável    |  
+---------+---------+---------+--------+---------+---------+-------------+

219 bytes por linha --> 8096 / 219 = 36,96 --> 36 linhas por Página.

*/
insert into DemoVarChar (id,Titulo,Descricao) values (4, replicate('D',100), replicate('d',100))

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from DemoVarChar as tab
  where id = 4 


 -------------------------------------------------------------------------------------
/*
Exemplo Prático  
*/
  
USE [DBDemo]
GO

drop table if exists tCliente_ComChar
go
drop table if exists tCliente_ComVarChar
go


CREATE TABLE tCliente_ComChar
(
	iIDCliente int NOT NULL,
	iIDEstado int NOT NULL,
	cNome char(50) NOT NULL,
	cCPF char(14) NOT NULL,
	cEmail char(65) NOT NULL,
	cCelular char(11) NOT NULL,
	dCadastro date NOT NULL,
	dNascimento date NOT NULL,
	cLogradouro char(50) NOT NULL,
	cCidade char(30) NOT NULL,
	cUF char(2) NOT NULL,
	cCEP char(8) NOT NULL,
	dDesativacao date NULL,
	mCredito money NOT NULL
) 
go
CREATE TABLE tCliente_ComVarChar
(
	iIDCliente int NOT NULL,
	iIDEstado int NOT NULL,
	cNome varchar(50) NOT NULL,
	cCPF varchar(14) NOT NULL,
	cEmail varchar(65) NOT NULL,
	cCelular varchar(11) NOT NULL,
	dCadastro date NOT NULL,
	dNascimento date NOT NULL,
	cLogradouro varchar(50) NOT NULL,
	cCidade varchar(30) NOT NULL,
	cUF varchar(2) NOT NULL,
	cCEP varchar(8) NOT NULL,
	dDesativacao date NULL,
	mCredito money NOT NULL
) 


Insert into tCliente_ComChar
select iIDCliente, iIDEstado, cNome, cCPF, cEmail, 
       cCelular, dCadastro, dNascimento, cLogradouro, 
       cCidade, cUF, cCEP,  dDesativacao, mCredito 
from eCommerce.dbo.tCliente
go
Insert into tCliente_ComVarChar
select iIDCliente, iIDEstado, cNome, cCPF, cEmail, 
       cCelular, dCadastro, dNascimento, cLogradouro, 
       cCidade, cUF, cCEP,  dDesativacao, mCredito 
from eCommerce.dbo.tCliente

/*
Descobrir quantas linhas por paginas de dados. 
*/
go
;
with ctePage as (
   select top 1000 
          plc.*, 
          tab.*
     from tCliente_ComChar as tab
     cross apply sys.fn_physLocCracker(%%PHYSLOC%% ) as plc

) select page_id, count(1)  
    from ctePage 
   group by page_id 


go
;
with ctePage as (
   select top 1000 
          plc.*, 
          tab.*
     from tCliente_ComVarChar as tab
     cross apply sys.fn_physLocCracker(%%PHYSLOC%% ) as plc

) select page_id, count(1)  
    from ctePage 
   group by page_id 


/*
 -- Utilizando a DMV  sys.dm_db_database_page_allocations
 Uma DMV não documentada.
 Ela tem 5 parâmetros.

 DB_ID				- ID do banco de dados. Vc pode obter esse id usando a função DB_ID()
 OBJECT_ID			- ID do objeto de alocação de dados. Utiliza a função OBJECT_ID() para obter o ID.
 INDEX_ID			- ID do índice. Vamos assumir NULL.
 PARTITION_NUMBER	- Número da partição da tabela. Vamos assumir NULL.
 MODO             - LIMITED OU DETAILED 

 Ref.: https://www.dbbest.com/blog/looking-inside-database-pages/

*/

 select allocation_unit_type_desc , 
        extent_page_id , 
        allocated_page_page_id , 
        page_type_desc
   from sys.dm_db_database_page_allocations(db_id(),
                                            object_id('tCliente_ComChar'),
                                            null,
                                            null,
                                            'DETAILED')

GO

select allocation_unit_type_desc , 
        extent_page_id , 
        allocated_page_page_id , 
        page_type_desc 
   from sys.dm_db_database_page_allocations(db_id(),
                                            object_id('tCliente_ComVarChar'),
                                            null,
                                            null,
                                            'DETAILED')
