 go
 drop table if exists DemoVarChar1
 go

 Create Table DemoVarChar1 (
   id int  not null , 
   nome char(10) not null , 
   data datetime  not null
 )
go


insert into DemoVarChar1 (id,nome,data ) values (1,'JOSE','1970-01-10')

select * from DemoVarChar1
select ascii('J'),ascii('O'), ascii('S'), ascii('E')
74	79	83	69
select char(225)




/*
    4 bytes de cabecalho da linha
    4 bytes para a coluna ID (INT) 
    8 bytes 
    1 bytes
10000 bytes para a coluna TITULO 
10000 bytes para a coluna DESCRICAO 

*/


-- ( 1000+2 + 1000+2 + 4 ) - 2008 por linha --> 4 linhas por página e sobre 44 bytes por página 
/*
4 Cabecalho

*/

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico
       
  from DemoVarChar1 as tab

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
dbcc page(6, 1, 353, 1) 

