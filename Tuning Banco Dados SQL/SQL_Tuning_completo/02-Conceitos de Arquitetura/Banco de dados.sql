/*
Dicas para criar um banco de dados com alto desempenho.

Como todos sabemos, um banco de dados é o local onde confiamos para que 
as aplicações guardem os dados e mantenha os integros e seguros.

Mas também, o banco de dados devem garantir que o dados seja acessado o mais rápido possivel.

Na realidade, não é o banco que deve garantir, mas quem o criou e configurou o 
banco de dados, o serviço do SQL Server instalado e as configurações do sistema operacional. 

Em suma, voce que está vendo esse treinamento é o responsável que deve garantir o acesso com 
desempenho dos dados armazenados no banco de dados. 

Vamos então ver quais são essas configurações que devem realizar para garantir
o alto desempenho da consultas.
*/


/*
Servidor 
--------

1. Discos.

   - Preferencialmente devem ser rápidos. Discos SSD são benvindos, devido a sua
     alta performance e em contra-partida temos o custo elevado. 
     Discos com tecnologia Fibre Channel são mais acessíveis e garante 
     alta performance. De preferência a discos que tenham 15K e evite os discos de grande
     capacidade com 1Tb ou mais. 

     Ref.: https://technet.microsoft.com/pt-br/library/dn610883%28v=ws.11%29.aspx?f=255&MSPPError=-2147217396

   - Utilizem vários discos para distribuição de carga de dados. Nada impede de voce 
     instalar tudo em um único disco. Mas voce incorre a problemas de desempenho do 
     SO e banco de dados como também sérios problemas de segurança.

     Boas práticas.
     --------------

     1 Disco para o SO
     1 Disco para dados, índices e área temporária 
     1 Disco para log       

     1 Disco para SO
     1 Disco para dados e índices
     1 Disco para log
     1 Disco para área temporária 

     1 Disco para SO
     1 Disco para dados 
     1 Disco para índices
     1 Disco para log
     1 Disco para área temporária 
          
   - Utilize formatação de blocos de 64K para discos onde serão gravados os dados.
*/

select * from sys.dm_os_enumerate_fixed_drives

/*

2. Memória.

   - Quanto mais, melhor. Memória será utilizada para carregar os dados que estão em 
     disco para um área no SQL Server conhecida como Buffer Pool.

   - Quando mais dados o SQL Server conseguir manter em memória, melhor. Servidores com 
     16Gb, 32GB ou 64Gb atende a maioria das demandas. Mas encontramos instalações que 
     chegam a mais de 512Gb de memória. 

     Apesar da recomendação mínima da Microsoft para memória do SQL Server é de 1Gb, 
     eu recomendo inicial com 4Gb, mas o correto deve ser a analíse do ambiente para 
     um melhor dimensionamento.

3. CPU

   - Processador ou core está relacionado diretamente a velocidade de processamento como
     também a forma como o licenciamento do SQL Server deve ser adquirido. 
   - Quanto mais rápido melhor. Olhando para o licenciamento, voce deve ter uma CPU com
     pelo menos 2 core. Recomenda-se iniciar com 4 cores, mas vale a análise do ambiente.


Sistema Operacional - Windows 
-----------------------------

1. Windows Server a partir da versão 2016 Standard. Claro que quanto maior a edição,
   mais recursos de hardware voce poderá utilizar. Por exemplo, o total de núcleos de CPU
   que uma versão do SQL Server suporte é limitada ao máximo que o Windows Server suporta. 

2. Configuração de plano de energia. 

   - Um servidor de banco de dados sempre ficará ligado e não será necessário um monitor ligado 24
     horas e, novamente, deve garantir alto desempenho. Existe uma configuração no Windows de plano
     de energia que voce configura para obter mais desempenho. 

   - Demonstração

3. Lock Page in Memory.

   O Windows Server "ainda" trabalha com o conceito de memória virtual em disco 
   (arquivo de paginação) que ele utiliza para paginar dados entre a memória fisica e a virutal.

   O conceito é transferir para o arquivo de paginação, dados que estão em memória mas não 
   estão em utilização pelas aplicações. Então o Windows transfere esses dados da memória
   física para a memória virtual. Se o dados for acessado pela aplicação, o Windows então
   carrega os dados da memória virtual e transfere para a memória física, fazendo uma troca 
   com os dados mais antigos em memória. 

   No caso do SQL Server, além de armazenar os dados em memória, ele também armezana informações
   sobre as tabelas, planos de execução entre outros que podem ser raramente acessados. Com isso,
   eles podem ser enviados para o arquivo de paginação.

   Para enviar isso, o Windows tem um mecanismo que impede essa troca de dados. Esse mecanismo
   é uma permissão que é concedida a conta do usuário que executa o serviço do SQL SERVER 
   chamado de "Lock Pages in Memory" 

   Demonstração:

   - Identificando a conta que executa o serviço do SQL Server.
   - Conceder a permissão.

   Ref.: https://docs.microsoft.com/pt-br/sql/database-engine/configure-windows/enable-the-lock-pages-in-memory-option-windows

4. Performance Volume Maintenance Tasks.

   Quando o Windows recebe uma solitação do SQL SERVER para criar um um arquivo ou 
   aumentar um arquivo em disco, o Windows aloca esse espaço em disco e começa a preencher 
   com zeros. Esse procedimento é o padrão para substituir dados de arquivos que foram excluídos.
   Então isso leva um certo tempo, até o processo terminar e o Windows liberar o arquivo para  
   o SQL Server.
   
   Quando você está criando um banco de dados para colocar um sistema em produção ou criando um
   novo servidor, o fato de Windows preencher com zeros o conteúdo dos arquivos não é tão crítico 
   pois não existe nesse momento um necessidade das consultas terem um alto desempenho.

   Mas quando temos um banco em produção com diversas consultas em execução, o SQL SERVER 
   por meio dos seus mecanismos interno, solicita ao Windows um aumento no tamanho do arquivo 
   de dados. Quando o Windows recebe essa solicitação, ele inicia a alocação do espaço solicitado,
   preenche esse espaço com zeros e devolve ao SQL Server o arquivo modificado. Esse tempo de alocar, 
   preencher e devolver, pode afetar o tempo de execução das consultas.

   Existe uma forma de impedir que o Windows execute a etapa de preencher com zeros, realizando
   somente a alocação do espaço e a devolução do arquivo para o SQL Server. 

   É uma outra permissão que é concedida a conta do usuário que executa o serviço do SQL SERVER 
   chamado de "Performance Volume Maintenance Tasks" 

   Demonstração:

   Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/databases/database-instant-file-initialization


SQL Server 
----------

1. Configurando a memória no SQL SERVER.

   Quando instalamos o SQL SERVER, ele configura automáticamente a utilização da memória disponível
   no servidor. Ele tem as opções de "Max Server Memory" e "Min Server Memory"  que voce pode consultar
   com o seguinte comando:
*/

execute sp_configure 'show advanced options' , 1
go
reconfigure with override 

execute sp_configure 'min memory per query (KB)'
execute sp_configure 'max server memory (MB)'

/*
   Na execução acima temos 1024Kb de memoria mínima e  2147483647KB(?) de memoria máxima.
   2 Tb de memória máxima? 

   Min Server Memory, não significa memória mínima que o SQL SERVER utiliza.
   
   - Quando inicializamos o serviço do SQL Server, ele aloca inicialmente 128Kb e espera as atividades
     de inclusão, alteração e exclusão de dados pela aplicação. No decorrer da execução das consultas, 
     o SQL SERVER carrega os dados do disco e aloca na memória que ele reservou. Essa memória inicial 
     até atingir o valor de 'Min Server Memory' é do SQL SERVER e ele não entrega ao SO, se ele solicitar. 

     Quando a alocação ultrapassa esse valor mínimo, O SQL Server continua a alocar mais memória. Mas se 
     por algum motivo, o SO solicitar memória do SQL Server, o mesmo pode liberar a memória, mas até 
     atingir o limite mínimo.

   Max Server Memory, não significa memória máxima que o SQL SERVER utiliza. 

   - Quando o SQL SERVER continua a realizar a alocação de dados do disco para a memória, ele somente 
     realiza as alocações até atingir o valor de 'Max Server Memory'. Se o SQL Server precisar alocar 
     novos dados em memoria, ele começa grava em discos os dados mais antigos em discos, liberar a area 
     da memória e aloca os novos dados. 

     Se o SO não tiver memória suficiente para trabalhar ou para outras aplicações alocarem seus dados,
     o SO solicita ao SQL Server memória. Se a memória do SQL SERVER reservado não estivar alocada com 
     dados, ele liberação essa memória para o SO. Se esse memória estiver alocação, o SQL Server grava
     os dados em disco e libera a memoria para o SO. 

     O SQL Server liberar memória até atingir o valor de 'Min Server Memory'

     ReF.: https://www.youtube.com/watch?v=OijdLj4lw5c

*/

-- Visualizando memoria total do servidor 

select total_physical_memory_kb / 1024.0     as MemoriaTotal ,
       available_physical_memory_kb / 1024.0 as MemoriaDisponivel 
from sys.dm_os_sys_memory

/*
MemoriaTotal	MemoriaDisponivel
------------   -----------------
 2047.421875	       403.734375
*/


execute sp_configure 'min memory per query (KB)' , 512
go
reconfigure with override 
go
execute sp_configure 'max server memory (MB)' , 1536
go
reconfigure with override 


select db_name(database_id) as BancoDeDados, 
       (count(1) * 8192 ) / 1024 /1024
  from sys.dm_os_buffer_descriptors
group by db_name(database_id)  


/*

2. Configuração do banco TEMPDB

   O banco de dados TEMPDB é um entre os diversos bancos de dados chamados de banco 
   de sistemas do SQL SERVER como o MASTER, MSDB, MODEL. O papel do TEMPDB é ser 
   uma área temporária de dados. Ele pode ser usando para criar tabelas temporárias, 
   indices, versionamento de linhas de transações, armazenamento de tabelas do tipo variáveis, 
   resultados intermediários de GROUP BY, ORDER BY ou UNION, etc..

   Quando uma consulta é executada pela aplicação, em algum momento ela deve carregar os dados
   para serem processados no CPU. O processo por sua vez pode exigir que dados criados pela 
   consulta fiquem registrados em uma área temporária. 

   Para isso, o SQL Server utiliza o TEMPDB. Ele acessa o banco de dados, cria uma tabela 
   temporária e grava os dados nessa tabela. 
   
   Como um banco de dados é formado no mínimo por um arquivo de dados, toda a demanda de
   criar dados no TEMPDB deve passar por um único arquivo de dados. 

   Em sistema de grandes capacidades e processamento, esse acesso por um único arquivo
   pode gerar a chamada contenção do TEMPDB. onde pode-se gerar um fila para acesso aos dados 
   temporários. 

   Se temos uma instalação do SQL Server em um servidor com 4 cores, cada um deles pode
   receber diversas solicitações de processamento e consequentemente solicitar para armazenar
   dados no TEMPDB. Como o acesso a CPU é superiormente mais rápido que o acesso a disco,
   os processos em cada core ficam aguardando a resposta do TEMPDB. 

   Agora imagine uma instalação com 32 cores !!!

   Para diminuir essas contenção, podendos criar ou adicionar arquivos de dados no banco de 
   dados TEMPDB. 

*/

use tempdb
GO

select * from sys.sysfiles

use master
go

Alter database Tempdb modify file ( name = tempdev , filename = 'G:\Tempdb.mdf')
go
Alter database Tempdb modify file ( name = templog , filename = 'G:\Templog.ldf')
go
Alter database Tempdb add file ( name = tempdev1 , filename = 'G:\Tempdev1.ndf')
go
Alter database Tempdb add file ( name = tempdev2 , filename = 'G:\Tempdev2.ndf')
go
Alter database Tempdb add file ( name = tempdev3 , filename = 'G:\Tempdev3.ndf')
go

/*



-------------sf
Banco de dados..

   Definição clássica: Um banco de dados é uma coleção de tabelas estruturadas que 
   armazena um conjunto de dados.......

   O que interessa. Os dados armazenados ficam registrados em arquivos em disco.
   Cada banco de dados no SQL Server tem no mínimo dois arquivos. Uma arquivo de dados
   conhecido como arquivo Primário e tem a extensão MDF e outro arquivo de log 
   com a extensão LDF para registrar os log de transção (vamos tratar somente de
   arquivo de dados neste treinamento). 

   No MDF além de termos os dados da aplicação, temos também informações sobre a 
   inicialização do banco de dados e a referência para outros arquivos de dados, como 
   também os metadados de todos os objetos de banco de dados criados pelos desenvolvedores.

   Existe um outro tipo de arquivo conhecido como Secundário onde contém somente os dados
   da aplicação. Ele tem a extensão NDF.

   Cada arquivo de dados:

      - Será agrupado junto com outros arquivos de dados em um grupo lógico chamado
        de FILEGROUP (FG). Se não especificado, o arquivo fica no grupo de arquivo PRIMARY.

      - Deve ter um nome lógico que será utilizado em instruções T-SQL 

      - Deve ter um nome físico onde consta o local o arquivo no sistema operacional.

      - Dever ter um tamannho inicial para atender a carga de dados atual e uma previsão
        futura.  

      - Deve ter uma taxa de crescimento definida. Ela será utiliza para aumentar o 
        tamanho do arquivo de dados quando o mesmo estiver cheio.

      - Deve ter um limite máximo de crescimento. Isso é importante para evitar 
        que arquivos crescem é ocupem todo o espaço em disco. 

Exemplos de criação de banco de dados 

*/

CREATE DATABASE DBDemo_01
GO

USE DBDemo_01
GO

Select * from sys.sysfiles

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles

use Master
go

drop database DBDemo_01
GO

/*

*/
DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY                                   -- FG PRIMARY 
 ( NAME = 'Primario',                        -- Nome lógico do arquivo
   FILENAME = 'D:\DBDemoA_Primario.mdf' ,    -- Nome físico do arquivo
   SIZE = 256MB                              -- Tamanho inicial do arquivo 
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

use DBDemoA
go

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles
go

/*
*/
Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 256MB 
 ),                                             -- Segundo Arquivo de dados, no mesmo FG
 ( NAME = 'Secundario',                         
   FILENAME = 'E:\DBDemoA_Secundario.ndf' , 
   SIZE = 256MB 
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

/*
   No exemplo acima, temos dois arquivos de dados no FG PRIMARY. Os dados gravados
   nesse grupo serão distribuidos de forma proporcional dentro dos arquivos 
*/

use DBDemoA
go

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles

/*

FILEGROUP
---------

   FILEGROUP é um agrupamento lógico de arquivos de dados para distribuir melhor a 
   alocação de dados entre os discos, agrupar dados de acordo com contextos ou 
   arquivamentos como também permitir ao DBA uma melhor forma de administração.

   No nosso caso, vamos focar em melhorar o desempenho das consultas.
      
*/

Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 64MB 
 ), 
FILEGROUP DADOS
 ( NAME = 'DadosTransacional1', 
   FILENAME = 'E:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'E:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO

ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT
GO

USE DBDemoA
GO
Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles

use eCommerce
select 488*8

SELECT * FROM SYS.dm_db_file_space_usage


/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-file-space-usage-transact-sql

*/


CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 64MB ,
   MAXSIZE =  
 ), 
FILEGROUP DADOS
 ( NAME = 'DadosTransacional1', 
   FILENAME = 'E:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'E:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB
 ) ,
FILEGROUP DADOSHISTORICO
 ( NAME = 'DadosHistorico1', 
   FILENAME = 'E:\DBDemoA_SecundarioH1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosHistorico2', 
   FILENAME = 'E:\DBDemoA_SecundarioH2.ndf' , 
   SIZE = 1024MB
 ) 

LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO


/*
Analisando o Banco
*/

use DBDemoA
go

select * from sys.sysfiles
select 131072 * 8192/1024 /1024


