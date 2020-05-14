/*

Page Split (Divisão de páginas)
--------------------------------

- A divisão de uma página (page split) ocorre quando uma tentativa de alocar um nova linha e não
  existe mais espaço na página e o SQL Server cria uma nova página. Essa alocação pode ser 
  um INSERT ou quando ocorre um UPDATE e o tamanho da linha é expandido. 

  Página de índice 
  Chave = Nome e ID
  +---------------+
  |APARECIDA123459|
  |BRUNO5487568932|
  |CAROLINA5412545|
  |DANIEL546766671|
  |FABIO4655656555|
  |GUSTAVO56655655| 
  +---------------+
  
  INSERT INTO TABELA (NOME, ID) VALUES ('ELOISA',656476345)

  +---------------+   +---------------+   
  |APARECIDA123459|   |ELOISA656476345|
  |BRUNO5487568932|   |FABIO4655656555|
  |CAROLINA5412545|   |GUSTAVO56655655|
  |DANIEL546766671|   |               |
  |               |   |               |
  |               |   |               | 
  +---------------+   +---------------+


- O processo de page split consiste em:

  1. Criar uma nova página;
  2. Transferir metade (+-) dos registros da página atual para a nova página;
  3. Realizar o INSERT ou UPDATE;
  4. Atualizar os ponteiros entre as páginas.

- O processo de realizar um page split tem um custo alto, pois envolve I/O de disco. E quando
  temos altas taxa de execução, isso afeta diretamente o desempenho. 

- Page Splits sempre existirão. Toda nova alocação de páginas para inclusões sempre realizarão 
  divisão de páginas. O que temos que fazer é reduzir a incidência de page splits.

  Por exemplo: Um índice que é chave primária, numérico, sequencial e crescente. Onde ocorrerão
  a inclusão de novas linhas? 
  
  Sempre no final da última página. Encheu a última página, page split e continua na próxima página. 
  A redução de page splits neste caso é criar o índice o mais curto possível. 
  
*/


/*
Page Split no processo de INSERT 
*/
use DBDemo
go

drop table if exists tDemoPageSplit 
go

Create Table tDemoPageSplit (id numeric(11), cNome char(800)) 
go

Create Clustered Index idcDemo on tDemoPageSplit (cNome, id)
go

insert into tDemoPageSplit (cNome, id )
values ('APARECIDA' ,34534534),('BRUNO',344345345),('CAROLINA',3453453453),
       ('DANIEL',4353434),('FABIO',34545343),
       ('GUSTAVO',4556456),('HELOI',434534534),('IVAN',45456546),('JOAQUIM',3453454),
       ('KATIA',34534534)
go
Select *   From tDemoPageSplit 
go

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as RID , * 
  From tDemoPageSplit 
go

/*
RID	      id	         cNome
(1:489:0)	34534534	   APARECIDA   
(1:489:1)	344345345	BRUNO       
(1:489:2)	3453453453	CAROLINA    
(1:489:3)	4353434	   DANIEL      
(1:489:4)	34545343	   FABIO       
(1:489:5)	4556456	   GUSTAVO     
(1:489:6)	434534534	HELOI       
(1:489:7)	45456546	   IVAN        
(1:489:8)	3453454	   JOAQUIM     

(1:492:0)	34534534	   KATIA       
*/
Alter Event Session xeMonitora_eCommerce 
   on Server
State = Start 
go
Insert into tDemoPageSplit (cNome, id )
Values ('ELOISA' ,3454534)
go

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% )  as RID, * 
  From tDemoPageSplit 
go

/*
RID	      id	         cNome
(1:489:0)	34534534	   APARECIDA   
(1:489:1)	344345345	BRUNO       
(1:489:2)	3453453453	CAROLINA    
(1:489:3)	4353434	   DANIEL      
(1:489:4)	3454534	   ELOISA      

(1:493:0)	34545343	   FABIO       
(1:493:1)	4556456	   GUSTAVO     
(1:493:2)	434534534   HELOI       
(1:493:3)	45456546	   IVAN        
(1:493:4)	3453454	   JOAQUIM     

(1:492:0)	34534534	   KATIA       
*/


/*
Fator de Preenchimento ou Fill Factor
--------------------------------------

- Valor entre 1% e 100% que determina o percentual de preenchimento de uma página de dados quando criamos
  ou alteramos um índice e determina (pelo valor da diferença) o espaço livre para crescimento futuro. 

- Um índice criado com um Fill Factor = 80, determina que 80% da página será preenchida unicamente e
  exclusivamente no momento da criação ou alteração do índice. Sendo que 20% ficará livre para que 
  novas alocações de dados não necessite realizar page split.

- O espaço livre será alocado entre os registros da página e não no final da página.

- Para criar um índice com o fator de preenchimento, utilize a cláusula FILLFACTOR = Valor, conforme exemplo abaixo: 

Create Index <NomeIndice> on <NomeTabela> (<Coluna1>,<Coluna2>,...) with (FILLFACTOR=<Valor>)
*/

use DBDemo
go

drop table if exists tDemoPageSplit 
go

Create Table tDemoPageSplit (id numeric(11), cNome char(800)) 
go

Create Clustered Index idcDemo on tDemoPageSplit (cNome, id) with (fillfactor = 75)
go

insert into tDemoPageSplit (cNome, id )
values ('APARECIDA' ,34534534),('BRUNO',344345345),('CAROLINA',3453453453),
       ('DANIEL',4353434),('FABIO',34545343),
       ('GUSTAVO',4556456),('HELOI',434534534),('IVAN',45456546),('JOAQUIM',3453454),
       ('KATIA',34534534)
go

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as RID, * 
  From tDemoPageSplit 
go

/*
???? 
RID	      id	         cNome
(1:489:0)	34534534	   APARECIDA   
(1:489:1)	344345345	BRUNO       
(1:489:2)	3453453453	CAROLINA    
(1:489:3)	4353434	   DANIEL      
(1:489:4)	34545343	   FABIO       
(1:489:5)	4556456	   GUSTAVO     
(1:489:6)	434534534	HELOI       
(1:489:7)	45456546	   IVAN        
(1:489:8)	3453454	   JOAQUIM     
(1:492:0)	34534534	   KATIA       
*/
/*
Veja, o efeito do fator de preenchimento somente é realizado 
no momento de criação, alteração ou reconstrução de um índice.  
*/

-- Reconstruindo o índice 
Alter Index idcDemo on tDemoPageSplit Rebuild with (fillfactor = 75)

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as RID , * 
  From tDemoPageSplit 
go

/*
RID	      id	         cNome
(1:493:0)	34534534	   APARECIDA       
(1:493:1)	344345345	BRUNO           
(1:493:2)	3453453453	CAROLINA        
(1:493:3)	4353434	   DANIEL          
(1:493:4)	34545343	   FABIO           
(1:493:5)	4556456	   GUSTAVO         
(1:493:6)	434534534	HELOI           
(1:493:7)	45456546	   IVAN            

(1:497:0)	3453454	   JOAQUIM         
(1:497:1)	34534534	   KATIA           
*/

Insert into tDemoPageSplit (cNome, id )
Values ('ELOISA' ,3454534)
go

Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as RID, * 
  From tDemoPageSplit 
/*
RID	      id	         cNome
(1:493:0)	34534534	   APARECIDA       
(1:493:1)	344345345	BRUNO           
(1:493:2)	3453453453	CAROLINA        
(1:493:3)	4353434	   DANIEL          
(1:493:4)	3454534	   ELOISA          
(1:493:5)	34545343	   FABIO           
(1:493:6)	4556456	   GUSTAVO         
(1:493:7)	434534534	HELOI           
(1:493:8)	45456546	   IVAN            

(1:497:0)	3453454	   JOAQUIM         
(1:497:1)	34534534	   KATIA           
*/

/*
Algumas considerações:

- O uso do fator de preenchimento poderá exigir uma alocação a mais de quantidade de páginas de dados. 
  Quanto mais baixo o fill factor, maior será a alocação de páginas de dados e consequentemente as
  instruções de consulta terão que ler um número maior de páginas de dados. 

- Após criar ou alterar um índice e definir o fator de preenchimento, as nova páginas alocadas pelos  
  INSERT não são afetas pelo FILL FACTOR. 

- Se você utiliza um índice clusterizado como chave primária e ele foi definido como númerico
  e auto incremental, as novas linhas que serão incluídas sempre ficarão na última página do
  índice e se não houver mais espaço, o SQL Server alocará uma nova página. Nesse tipo de índice,
  não ocorrerá (rs!!) inclusão de novas linhas no meio do índice. Nesse caso o FILL FACTOR desse
  tipo de indice pode ser 100. 



*/

use DBDemo
go

drop table if exists tDemoPageSplit 
go

Create Table tDemoPageSplit (id numeric(11), cNome char(800)) 
go

insert into tDemoPageSplit (cNome, id )
values ('APARECIDA' ,34534534),('BRUNO',344345345),('CAROLINA',3453453453),
       ('DANIEL',4353434),('FABIO',34545343),
       ('GUSTAVO',4556456),('HELOI',434534534),('IVAN',45456546),('JOAQUIM',3453454),
       ('KATIA',34534534)
go

Create Clustered Index idcDemo on tDemoPageSplit (cNome, id) with (fillfactor = 50)
go


Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) , * 
  From tDemoPageSplit 
go

insert into tDemoPageSplit (cNome, id )
values ('XAPARECIDA' ,34534534),('XBRUNO',344345345),('XCAROLINA',3453453453),
       ('XDANIEL',4353434),('XFABIO',34545343),
       ('XGUSTAVO',4556456),('XHELOI',434534534),('XIVAN',45456546),('XJOAQUIM',3453454),
       ('XKATIA',34534534)

insert into tDemoPageSplit (cNome, id )
values ('YAPARECIDA' ,34534534),('YBRUNO',344345345),('YCAROLINA',3453453453),
       ('YDANIEL',4353434),('YFABIO',34545343),
       ('YGUSTAVO',4556456),('YHELOI',434534534),('YIVAN',45456546),('YJOAQUIM',3453454),
       ('YKATIA',34534534)


Select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) , * 
  From tDemoPageSplit 


/*
*/
select i.name as cIndex , 
       object_name(p.object_id) as cTable,
       b.page_id ,
       b.row_count ,
       b.free_space_in_bytes ,
       100-((b.free_space_in_bytes /8096.0)*100) 
  from sys.dm_os_buffer_descriptors b -- Contém as informações do Buffer 
  join sys.allocation_units a         -- Informações de unidade de alocação dos objetos
    on b.allocation_unit_id = a.allocation_unit_id
  join sys.partitions p               -- Partições dos objetos de alocação.
    on a.container_id = p.partition_id
  join sys.indexes i
    on p.index_id = i.index_id and p.object_id = i.object_id
 where p.object_id = object_id('tDemoPageSplit')
   and b.page_type in ( 'DATA_PAGE' )
   and b.database_id = DB_ID()
order by page_id 
go


Alter Index idcDemo on tDemoPageSplit rebuild with (fillfactor = 100)
go


