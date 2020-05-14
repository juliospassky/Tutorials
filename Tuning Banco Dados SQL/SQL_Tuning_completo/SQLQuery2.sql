 go
 drop table if exists DemoVarChar
 go

 Create Table DemoVarChar (
   id int  not null , 
   Titulo varchar(4000) not null , 
   Descricao varchar(4000) not null
 )
go


declare @titulo varchar(4000)    = 'WOLNEYCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC'
declare @Descricao varchar(4000) = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'

insert into DemoVarChar (id,Titulo,Descricao) values (2147483647,@titulo,@Descricao)

select * from DemoVarChar
select ascii('W'),ascii('O'), ascii('L')
select char(225)




/*
                    HEADER   ID                          
                    -------- -------- -------- -------- --------
0000000000000000:   30000800 ffffff7f 03000002 00f903e1 07574f4c  0...ÿÿÿ......ù.á.WOL
0000000000000014:   4e455943 43434343 43434343 43434343 43434343  NEYCCCCCCCCCCCCCCCCC

https://www.sqlskills.com/blogs/paul/inside-the-storage-engine-anatomy-of-a-record/
/*
A estrutura de registro para registros não compactados é a seguinte:

Cabeçalho do registro
   4 bytes de comprimento
   Dois bytes de metadados recados (tipo de registro)
   Dois bytes apontando para a frente no registro para o bitmap nulo
Porção de comprimento fixo da gravação, contendo as colunas que armazenam tipos de dados que possuem comprimentos fixos (por exemplo , bigint , char (10) , datetime )
Mapa de bits nulo
   Dois bytes para a contagem de colunas no registro
   Número variável de bytes para armazenar um bit por coluna na gravação, independentemente de a coluna ser ou não anulável (isso é diferente e mais simples do que o SQL Server 2000, que tinha apenas um bit por coluna nula)
   Isso permite uma otimização ao ler colunas que são NULL
Conjunto de compensação de coluna de comprimento variável
   Dois bytes para a contagem de colunas de comprimento variável
   Dois bytes por coluna de comprimento variável, dando o deslocamento para o final do valor da coluna
*/

    4 bytes de cabecalho da linha
    n bytes para a colunas de tamanho fixo 
    4 bytes, 2 bytes para cada VARCHAR 

    1 byte para null
    2 bytes, se existir VARCHAR
   
 1000 bytes para a coluna TITULO 
 1000 bytes para a coluna DESCRICAO 


*/


-- ( 1000+2 + 1000+2 + 4 ) - 2008 por linha --> 4 linhas por página e sobre 44 bytes por página 
/*
4 Cabecalho

*/

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       4 as id , datalength(titulo) as titulo, datalength(descricao) as descricao 
  from DemoVarChar as tab

 select allocation_unit_type_desc , 
        extent_page_id , 
        allocated_page_page_id , 
        page_type_desc , page_free_space_percent 
   from sys.dm_db_database_page_allocations(db_id(),
                                            object_id('DemoVarchar'),
                                            null,
                                            null,
                                            'DETAILED')


dbcc traceon(3604)
dbcc page(6, 1, 352, 1) 

