Use Master
go

alter database DBDemo set single_user with rollback immediate 
go
drop database DBDemo

Create Database DBDemo
go

Alter Database DBDemo SET MIXED_PAGE_ALLOCATION ON



use DBDemo
go

--select * from vDataTypes

Create or Alter view vDataTypes 
as 
select system_type_id , 
case when system_type_id  in (104,127,56,52,48,60,122) then 'Numerico Exato'
     when system_type_id  in (35,99) then 'Large Object - LOB'
     when system_type_id  in (40,41,42,43,58,61) then 'Data e Hora '
     when system_type_id  in (62,59) then 'Numérico Aproximado'
     when system_type_id  in (106,108) then 'Numérico com precisão'
     when system_type_id  in (167) then 'Comprimento variável'
     when system_type_id  in (175) then 'Comprimento fixo'
     when system_type_id  in (231) then 'Comprimento variável UNICODE'
     when system_type_id  in (239) then 'Comprimento fixo UNICODE'
     when system_type_id  in (173,165,34) then 'Binária '
     else 'Outros tipos' 
     end Grupo ,
Name, 
case when name in ('nvarchar','nchar' ) then 4000 else  max_length end  max_length , precision , scale  
from sys.types
where is_user_defined = 0 and user_type_id <> 256
union all
select 0 , 'Large Value ', 'varchar(max)', -1, 0,0
union all
select 0 , 'Large Value ', 'nvarchar(max)', -1, 0,0
union all
select 0 , 'Large Object - LOB', 'varbinary(max)', -1, 0,0





select * from sys.types