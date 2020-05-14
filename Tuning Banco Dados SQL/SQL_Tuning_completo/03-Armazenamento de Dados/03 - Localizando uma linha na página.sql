/*
Como sei que uma determinada linha ou dados estão em uma página?

No SQL Server, podemos utilizar de algumas formas para identificar 
a página de dados de uma linha ou as linhas contidas em uma página de dados.

Uma delas é usando a pseudo coluna %%PHYSLOC%% que retorna um hexadecimal com
o RID ( ROW IDENTIFIER ) do endereço físico da linha dentro de uma página.

Ref.: http://sqlity.net/en/2451/physloc/
      https://www.sqlskills.com/blogs/paul/sql-server-2008-new-undocumented-physical-row-locator-function/

*/

use DBDemo
go

select %%PHYSLOC%%  as LocalFisico, 
       DemoPage.* 
  from DemoPage

select %%PHYSLOC%%  as LocalFisico, 
       tCliente.* 
  from tCliente

/*
Utilize com moderação. De preferência em ambiente de treinamento, teste ou desenvolvimento. 

Para traduzir essa endereço em algo mais legível para nós, utilizaremos 
a função sys.fn_PhysLocFormatter que recebe esse coluna como parâmetro e retorna as
informações da localização da linha. 

*/

use DBDemo
go

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       DemoPage.* 
  from DemoPage

go

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tCliente.* 
  from tCliente



/*

(1:372:0) - 

1     - ID do Arquivo de dados.
372   - Número da Página de Dados.
0     - ID do Slot (Posição da linha dentro da página).

*/

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tCliente.* 
  from tCliente
  where iidcliente  = 150

/*



Outro exemplo: O cliente "Barry G. Ware" que tem o iIDCliente = 150 está em :

(1:5618:49)

1    - ID do Arquivo de dados.
5618 - Número da Página de Dados.
49   - ID do Slot (Posição da linha dentro da página).

Atenção !! : Esses valores podem ser diferentes em computadores diferentes.
Rodei esse exemplos várias vezes e em pelo menos 3 computadores e na maioria dos casos os valores mudam.
Isso acontece. Dados são incluidos, excluidos dentro do banco e a númeração das páginas podem mesmo mudar.


*/
use DBDemo
go

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tCliente.*
  from tCliente
    where iidcliente  = 150

select * from sys.dm_os_buffer_descriptors
where page_id = 5618 

select database_id, file_id , page_id ,page_type , 
       row_count, free_space_in_bytes , is_modified  
  from sys.dm_os_buffer_descriptors
 where page_id = 5618 and database_id = db_id()

update tCliente set mCredito = 100001
where iIDCliente = 150

select database_id, file_id , page_id ,page_type , 
       row_count, free_space_in_bytes , is_modified  
  from sys.dm_os_buffer_descriptors
 where page_id = 5618 and database_id = db_id()

-- Total de paginas limpas e "sujas" 
select is_modified,count(1) from sys.dm_os_buffer_descriptors group by is_modified
 
DBCC DROPCLEANBUFFERS 
-- Remove todos os buffers limpos do pool de buffers

select database_id, file_id , page_id ,page_type , 
       row_count, free_space_in_bytes , is_modified  
  from sys.dm_os_buffer_descriptors
 where page_id = 5618 and database_id = db_id()

Checkpoint
-- 
select database_id, file_id , page_id ,page_type , 
       row_count, free_space_in_bytes , is_modified  
  from sys.dm_os_buffer_descriptors
 where page_id = 5618 and database_id = db_id()

DBCC DROPCLEANBUFFERS 

select database_id, file_id , page_id ,page_type , 
       row_count, free_space_in_bytes , is_modified  
  from sys.dm_os_buffer_descriptors
 where page_id = 5618 and database_id = db_id()

