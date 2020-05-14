CREATE DATABASE DBDemoA
ON PRIMARY 
( NAME = 'Primario', FILENAME = 'C:\Dados\Primario.mdf' ), 
FILEGROUP DADOS 
( NAME = 'Dados', FILENAME = 'C:\Dados\Dados.ndf' )
LOG ON 
( NAME = 'LogTransacao', FILENAME = 'C:\Dados\LogTransacao.ldf')
GO
ALTER DATABASE DBDemoA MODIFY FILEGROUP DADOS DEFAULT
GO

/*


*/
use DBDemoA
go




select * from sys.dm_db_file_space_usage





