/*
 Visualizando o conteúdo de uma página de dados. 
 
 Ref.:
 https://blogs.msdn.microsoft.com/sqlserverstorageengine/2006/06/10/how-to-use-dbcc-page/
 https://www.sqlskills.com/blogs/paul/inside-the-storage-engine-anatomy-of-a-page/


 Comando que apresenta o conteúdo de uma página de dados. 

 DBCC PAGE ( db_id, file_id, page, opção )

 Voce tem quem informar :

 ID do Banco de dados, voce obtém pela função DB_ID().
 ID do arquivo, que pode ser obtido com a pseudo coluna %%PHYSLOC%%.
 Número da página.
 Número de opção, que pode 1,2 ou 3 que mostra diferentes formatos do conteúdo.

 Para que a saida do resultado da comando aparece na IDE, voce 
 tem que executar antes o abaixo comando:

 dbcc traceon(3604)
 
 */

use DBDemo
go

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from tAluno  as tab
go



dbcc traceon(3604)
go
declare @dbid int = db_id()
dbcc page(@dbid, 1, 484,1) 

/*

PAGE: (1:484)


BUFFER:


BUF @0x0000009CBED9DE00

bpage = 0x0000009CB1E20000          bhash = 0x0000000000000000          bpageno = (1:484)
bdbid = 6                           breferences = 0                     bcputicks = 0
bsampleCount = 0                    bUse1 = 5951                        bstat = 0x10b
blog = 0xac7acccc                   bnext = 0x0000000000000000          bDirtyContext = 0x0000009CB7B486E0
bstat2 = 0x0                        

PAGE HEADER:


Page @0x0000009CB1E20000

m_pageId = (1:484)                  m_headerVersion = 1                 m_type = 1
m_typeFlagBits = 0x0                m_level = 0                         m_flagBits = 0x8000
m_objId (AllocUnitId.idObj) = 242   m_indexId (AllocUnitId.idInd) = 256 
Metadata: AllocUnitId = 72057594053787648                                
Metadata: PartitionId = 72057594046775296                                Metadata: IndexId = 0
Metadata: ObjectId = 142623551      m_prevPage = (0:0)                  m_nextPage = (0:0)
pminlen = 27                        m_slotCnt = 1                       m_freeCnt = 8000
m_freeData = 190                    m_reservedCnt = 0                   m_lsn = (114:10669:59)
m_xactReserved = 0                  m_xdesId = (0:0)                    m_ghostRecCnt = 0
m_tornBits = 0                      DB Frag ID = 1                      

Allocation Status

GAM (1:2) = ALLOCATED               SGAM (1:3) = ALLOCATED              
PFS (1:1) = 0x61 MIXED_EXT ALLOCATED  50_PCT_FULL                        DIFF (1:6) = CHANGED
ML (1:7) = NOT MIN_LOGGED           

DATA:


Slot 0, Offset 0x60, Length 94, DumpStyle BYTE

Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
Record Size = 94                    
Memory Dump @0x0000009DE7AAA060

0000000000000000:   30001b00 b3150000 37383635 34333435 36353400  0...³...78654345654.
0000000000000014:   000000df 63000006 00000300 33004400 5e004a6f  ...ßc.......3.D.^.Jo
0000000000000028:   73652064 61205369 6c766141 762e2050 61756c69  se da SilvaAv. Pauli
000000000000003C:   7374612c 20313030 46616c74 61206170 72657365  sta, 100Falta aprese
0000000000000050:   6e746172 20646f63 756d656e 746f               ntar documento

OFFSET TABLE:

Row - Offset                        
0 (0x0) - 96 (0x60)                 

*/

Insert Into tAluno values (116024,'14367876871','1970-01-01','Wolney Marconi Maia','Rua da Mooca 1500','Falta apresentar histórico escolar.')

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from tAluno  as tab
go



dbcc traceon(3604)
go
declare @dbid int = db_id()
dbcc page(@dbid, 1, 484,1) 


/*
------------------------------------------------------------------------------------------------

PAGE: (1:484)


BUFFER:


BUF @0x0000009CBED9DE00

bpage = 0x0000009CB1E20000          bhash = 0x0000000000000000          bpageno = (1:484)
bdbid = 6                           breferences = 0                     bcputicks = 0
bsampleCount = 0                    bUse1 = 6346                        bstat = 0x10b
blog = 0xac7acccc                   bnext = 0x0000000000000000          bDirtyContext = 0x0000009CB7B486E0
bstat2 = 0x0                        

PAGE HEADER:


Page @0x0000009CB1E20000

m_pageId = (1:484)                  m_headerVersion = 1                 m_type = 1
m_typeFlagBits = 0x0                m_level = 0                         m_flagBits = 0x8000
m_objId (AllocUnitId.idObj) = 242   m_indexId (AllocUnitId.idInd) = 256 
Metadata: AllocUnitId = 72057594053787648                                
Metadata: PartitionId = 72057594046775296                                Metadata: IndexId = 0
Metadata: ObjectId = 142623551      m_prevPage = (0:0)                  m_nextPage = (0:0)
pminlen = 27                        m_slotCnt = 2                       m_freeCnt = 7889
m_freeData = 299                    m_reservedCnt = 0                   m_lsn = (114:10679:2)
m_xactReserved = 0                  m_xdesId = (0:0)                    m_ghostRecCnt = 0
m_tornBits = 0                      DB Frag ID = 1                      

Allocation Status

GAM (1:2) = ALLOCATED               SGAM (1:3) = ALLOCATED              
PFS (1:1) = 0x61 MIXED_EXT ALLOCATED  50_PCT_FULL                        DIFF (1:6) = CHANGED
ML (1:7) = NOT MIN_LOGGED           

DATA:


Slot 0, Offset 0x60, Length 94, DumpStyle BYTE

Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
Record Size = 94                    
Memory Dump @0x0000009DE6C7A060

0000000000000000:   30001b00 b3150000 37383635 34333435 36353400  0...³...78654345654.
0000000000000014:   000000df 63000006 00000300 33004400 5e004a6f  ...ßc.......3.D.^.Jo
0000000000000028:   73652064 61205369 6c766141 762e2050 61756c69  se da SilvaAv. Pauli
000000000000003C:   7374612c 20313030 46616c74 61206170 72657365  sta, 100Falta aprese
0000000000000050:   6e746172 20646f63 756d656e 746f               ntar documento

Slot 1, Offset 0xbe, Length 109, DumpStyle BYTE

Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
Record Size = 109                   
Memory Dump @0x0000009DE6C7A0BE

0000000000000000:   30001b00 38c50100 31343336 37383736 38373100  0...8Å..14367876871.
0000000000000014:   000000df 63000006 00000300 39004a00 6d00576f  ...ßc.......9.J.m.Wo
0000000000000028:   6c6e6579 204d6172 636f6e69 204d6169 61527561  lney Marconi MaiaRua
000000000000003C:   20646120 4d6f6f63 61203135 30304661 6c746120   da Mooca 1500Falta 
0000000000000050:   61707265 73656e74 61722068 697374f3 7269636f  apresentar histórico
0000000000000064:   20657363 6f6c6172 2e                           escolar.

OFFSET TABLE:

Row - Offset                        
1 (0x1) - 190 (0xbe)                
0 (0x0) - 96 (0x60)                 


DBCC execution completed. If DBCC printed error messages, contact your system administrator.



Analisando com o tipo de dados caracter UNICODE
*/

drop table if exists tCodigo 
go

Create Table tCodigo 
( id int ,
  Nome char(20),
  NomeInt nchar(20),
)

Insert into tCodigo (id, nome, nomeint) values (1,'Jose',N'ホセ')
Insert into tCodigo (id, nome, nomeint) values (1,'Jose',N'Jose')


select * from tcodigo

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from tCodigo as tab
go


dbcc traceon(3604)
go
declare @dbid int = db_id()
dbcc page(@dbid, 1, 17088, 1) 



