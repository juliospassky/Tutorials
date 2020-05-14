use DBDemo
go

drop table if exists tAluno
go

Create Table tAluno (
   Id int,                 
   Cpf char(11),           
   Nascimento datetime,    
   Nome varchar(50),       
   Endereco varchar(100),  
   Observacao varchar(100) 
)


/*
Armazenamento físico previsão

   Id int,                 -- Fixo       4 bytes. 
   Cpf char(11),           -- Fixo      11 bytes. 
   Nascimento datetime,    -- Fixo       8 bytes. 
   Nome varchar(50),       -- Variável  50 bytes máximo.
   Endereco varchar(100),  -- Variável 100 bytes máximo. 
   Observacao varchar(100) -- Variável 100 bytes máximo.
							         -----
						               273 bytes máximo.

Uma página de dados tem no total 8.192 bytes.
Se 96 bytes são de cabeçalho, sobra 8.096 bytes.
Então podemos alocar 29 linhas em uma página ( 8.096/273 ). 								

O raciocínio está correto!

Mas temos que aprender algumas outras configurações para entender
como esse armazenamento de linhas ocorre. 

*/


Insert Into tAluno values (
   123456,
   '12345678901',
   '1970-01-01 11:55:55' ,
   'Jose da Silva'  + replicate('A',37),
   'Av. Paulista, 100' + replicate('E', 83),
   replicate('O',100) 
)
GO 

Insert Into tAluno values (
   cast(rand()*10000 as int),
   cast( cast(rand()*100000000000 as bigint) as char(11)),
   dateadd(MINUTE,rand()*10000.0 * -24 * 60 ,getdate()) ,
   replicate('A',50),
   replicate('E', 100),
   replicate('O',100) 
)
GO 39

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, *  
  from tAluno
GO


Select *
  from sys.dm_os_buffer_descriptors
 where page_id in( 465,484) and database_id = db_id()


/*

Temos alguns fatores que contribui para que o SQL Server
armazene o maior número de linhas em um página, mas
as vezes esse valor é menor que esperamos. 

Um deles é como a linha é armazenada dentro de um página.

Calculando tamanho da linha dentro de uma página.
-------------------------------------------------
                  
- Uma linha de dados de uma tabela quando armazenada em um página é definida 
  como um registro.

+---------------------------------------------------------------+
|123456123456789011970-01-0111:55:55.000Jose da SilvaAAAAAAAAA...
+---------------------------------------------------------------+

- E esses registros são gravados na sequência, dentro da página de dados. 

------+----------------------------------------------------------------+----------------------------------------------------------------+
000...123456123456789011970-01-0111:55:55.000Jose da SilvaAAAAAAAAA....9061590231751342010-11-0308:48:31.427AAAAAAAAAAAAAAAAAAAAAAAA...|
------+----------------------------------------------------------------+----------------------------------------------------------------+

- O registro armazena os dados da linha (dados de persistência) e também 
  um conjunto de bytes de controle (dados de controle ou metadados) das 
  colunas e suas características.

- Um registro dentro de uma página será a sequência de "bytes de dados" e 
  "bytes de controle" intercalados. 
  
- A ordem como os dados são gravados dentro do registro é realizado pelo 
  SQL Server de forma a otimizar o armazenamento. Então, essa ordem não
  respeita a ordem que as colunas foram criadas. 

- O controle da posição do inicial do registro dentro página 
  será realizado pela área de matriz de slots.

- Uma linha recebe no mínimo 7 bytes a mais para controle do registro dentro da 
  página.

- A estrutura de um registro dentro de uma página é:
+---------+---------+---------+---------+---------+---------+----------+ 
| 4 bytes | n bytes | 2 bytes | n bytes | 2 bytes | n bytes | n bytes  | 
| Header  | Fixo    | QtdCol  | NullMap | ColVar  | OffVar  | Variável | 
+---------+---------+---------+---------+---------+---------+----------+ 
|         |         |         |         |         |         |- Dados de tamanho variável.
|         |         |         |         |         |         |
|         |         |         |         |         |- Cálculo de deslocamento de colunas variável. 
|         |         |         |         |         |  2 bytes para cada coluna.
|         |         |         |         |         |
|         |         |         |         |- Contagem de colunas de tamanho variável.
|         |         |         |         |
|         |         |         |-Mapear colunas null. Mapear até 8 colunas por byte.
|         |         |         |
|         |         |-contagem das colunas.   
|         |         |
|         |- Dados de tamanho fixo como INT, CHAR ou DATETIME por exemplo. 
|         |
|- Cabeçalho. Contém informações e características do Registro.


Considere ainda mais 2 bytes que será alocado na Matriz de Slot no
final da página. Essa matriz de slot é utilizada como ponteiro de 
início do registro dentro da página. 

Veja abaixo uma representação da estrutura de um registro. 





                           PÁGINA DE DADOS 
+------------------------------------------------------------------------+
|                                                                        |
|          CABEÇALHO (HEADER) DA PÁGINA - 96 BYTES                       |
|                                                                        |
+------------------------------------------------------------------------+
|+---------+---------+---------+--------+---------+---------+----------+ |
|| 4 bytes | n bytes | 2 bytes | n byte | 2 bytes | n bytes | n bytes  | |
|| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável | |
|+---------+---------+---------+--------+---------+---------+----------+ |
|+---------+---------+---------+--------+---------+---------+----------+ |
|| 4 bytes | n bytes | 2 bytes | n byte | 2 bytes | n bytes | n bytes  | |
|| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Variável | |
|+---------+---------+---------+--------+---------+---------+----------+ |
|                                                                        |
|                                                                        |
|                                                                        |
+------------------------------------------------------------------------+
| MATRIZ DOS SLOTS                                   | 2 bytes | 2 bytes |
+------------------------------------------------------------------------+







Complexo?! No seu dia-a-dia não será necessário realizar esses cálculos e nem 
será necessário examinar os registros como estamos fazendo agora.  

Mas esse entendimento ajuda a compreender como a linha é armazenada na página em forma
de registro. 

Vamos ver um exemplo inserindo esse conjunto de dados:

(5555,'78654345654','1970-01-01','Jose da Silva','Av. Paulista, 100','Falta apresentar documento')

5555786543456541970-01-01Jose da SilvaAv. Paulista, 100Falta apresentar documento

Se contarmos somente os dados, temos um total de 82 caracteres.

Vamos criar uma tabela para receber esses dados.

*/

use DBDemo
go

drop table if exists tAluno
go

Create Table tAluno (
   Id int,                 -- Fixo de  4 bytes. 
   Cpf char(11),           -- Fixo de 11 bytes. 
   Nascimento datetime,    -- Fixo de  8 bytes. 
   Nome varchar(50),       -- Variável de  50 bytes máximo.
   Endereco varchar(100),  -- Variável de 100 bytes máximo. 
   Observacao varchar(100) -- Variável de 100 bytes máximo.
)
go

/*
Realizando a soma somente dos bytes que serão utilizados para o armazenamento dos dados, temos :

Colunas de tamanho Fixo     =  23 bytes
Colunas de tamanho Variável =  56 bytes, considerando os dados que serão armazenados.
                                         (250 bytes, considerando o armazenamento máximo).

No total, temos 79 bytes utilizados para armazenar 82 caracteres. 

*/

Insert Into tAluno values (5555,'78654345654','1970-01-01','Jose da Silva','Av. Paulista, 100','Falta apresentar documento')

Select * From tAluno

/*
Vamos calcular como fica o armazenamento do registro na tabela, considerando
os bytes de controle: 

|- Cabeçalho da linha.
|         |- Dados de tamanho fixo.
|         |          |- Contagem de colunas (6) 
|         |          |         |- Mapeamente de NULL das colunas.
|         |          |         |        |- Contagem de colunas variáveis (3)
|         |          |         |        |         |- Deslocamento dos dados variáveis.
|         |          |         |        |         |         |- Dados variavéis
|         |          |         |        |         |         |
+---------+----------+---------+--------+---------+---------+----------+----------+---------+
| 4 bytes | 23 bytes | 2 bytes | 1 byte | 2 bytes | 6 bytes | 13 bytes | 17 bytes | 26 bytes| <-- REGISTRO 
+---------+----------+---------+--------+---------+---------+----------+----------+---------+


Total de 94 bytes

Matriz de Slots 
+---------+
| 2 bytes |
+---------+
------------------
Total de 96 bytes
------------------

Observações:

- Voce percebeu que os dados de todas as colunas não ficam na ordem 
  que foram criadas!! Em uma parte do registro temos os bytes das colunas de tamanho fixo.
  Depois temos os bytes de controle e por fim temos os bytes das colunas de tamanho variável. 

- Mesmo que você defina uma coluna de tamanho fixo como NULL e grava o NULL, 
  ela alocará o tamanho total de armazenamento com zeros. Pelos bytes de controle
  de mapeamento de NULL, que o SQL Server sabe se a coluna retornará o dado ou o NULL.

  
Ref.: http://aboutsqlserver.com/2013/10/15/sql-server-storage-engine-data-pages-and-data-rows/
      https://docs.microsoft.com/pt-br/sql/relational-databases/databases/estimate-the-size-of-a-database?view=sql-server-2017

*/


select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from tAluno  as tab


select *
  from sys.dm_os_buffer_descriptors
 where page_id = 484 and database_id = db_id()



/*
Utilizar duas visões do catálogo do sistemas:

sys.allocation_units		- Contém uma linha para cada unidade de alocação no banco de dados.
sys.partitions				- Contém uma linha para cada partição de todas as tabelas e para a 
                          maioria dos tipos de índices no banco de dados.

Ref.: 
https://docs.microsoft.com/pt-br/sql/relational-databases/system-catalog-views/sys-allocation-units-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/relational-databases/system-catalog-views/sys-partitions-transact-sql?view=sql-server-2017

PS: Partição : Recurso do SQL Server que permite dividir a tabela horizontalmente em várias partições.
               Se não utilizar esse recurso, a tabela é definida como um única partição. 
               
*/

select * 
  from sys.partitions pa
 where pa.object_id = object_id('tAluno')


Select pa.index_id , pa.rows  ,
       au.type, au.type_desc , au.data_space_id , au.total_pages , au.data_pages 
  From sys.partitions pa
  Join sys.allocation_units au
    on pa.partition_id  = au.container_id 
 where pa.object_id = object_id('tAluno')

/*

DMV : sys.dm_db_index_physical_stats

Retorna informações de tamanho e fragmentação dos dados. 
Para um heap, uma linha é retornada para a unidade de alocação de IN_ROW_DATA de cada partição. 

Ref.:
https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql?view=sql-server-2017

*/

declare @db_id int = db_id()
declare @object_id int = object_id('tAluno')

Select index_id , 
       index_type_desc , 
	   alloc_unit_type_desc , 
	   page_count , 
	   record_count  ,
	   min_record_size_in_bytes ,
	   max_record_size_in_bytes ,
	   avg_record_size_in_bytes
  from sys.dm_db_index_physical_stats(@db_id, @object_id , null,null,'DETAILED')


go

/*
*/

use DBDemo
go

Insert Into tAluno values (5555,'78654345654','1970-01-01','Jose da Silva','Av. Paulista, 100','Falta apresentar documento')
go 10000


select * 
  from sys.partitions pa
 where pa.object_id = object_id('tAluno')

 Select pa.index_id , pa.rows  ,
       au.type, au.type_desc , au.data_space_id , au.total_pages , au.data_pages 
  From sys.partitions pa
  Join sys.allocation_units au
    on pa.partition_id  = au.container_id 
 where pa.object_id = object_id('tAluno')


declare @db_id int = db_id()
declare @object_id int = object_id('tAluno')

Select index_id , 
       index_type_desc , 
	    alloc_unit_type_desc , 
	    page_count , 
	    record_count  ,
	    min_record_size_in_bytes ,
	    max_record_size_in_bytes ,
	    avg_record_size_in_bytes
  from sys.dm_db_index_physical_stats(@db_id, @object_id , null,null,'DETAILED')
