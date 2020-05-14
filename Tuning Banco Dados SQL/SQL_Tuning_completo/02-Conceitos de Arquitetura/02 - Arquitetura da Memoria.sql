/*
Vamos começar essa aula com a seguinte pergunta:

É mais rápido acessar os dados em memória ou em disco ?

A sua resposta já diz por que o SQL Server deve ter memória suficiente
para atender a carga de dados. 


Memória.

   - Quanto mais, melhor. Memória será utilizada para carregar os dados que estão em 
     disco para um área no SQL Server conhecida como Buffer Pool.

   - Quando mais dados o SQL Server conseguir manter em memória, melhor. Servidores com 
     16Gb, 32GB ou 64Gb atende a maioria das demandas. Mas encontramos instalações que 
     chegam a mais de 512Gb de memória. 

     Apesar da recomendação mínima da Microsoft para memória do SQL Server é de 1Gb, 
     eu recomendo inicial com 4Gb, mas o correto deve ser a análise do ambiente para 
     um melhor dimensionamento.
*/

/*

SQL Server 
----------

Buffer Pool ou Buffer Cache.

Um buffer é uma área de 8Kbytes na memória onde o SQL Server armazena as páginas  de dados 
lidas dos objetos de alocação que estão no disco ( papel do Gerenciador de Buffer). 

O dado permanece no buffer até que o Gerenciador de Buffer precise de mais áreas para carregar
novas páginas de dados. As áreas de buffer mais antigas e com dados modificados são gravos em discos
e liberadas para os novas páginas. 

Quando o SQL Server necessita de um dado é o mesmo está no buffer, 
ele faz uma leitura lógica desse dado. Se o dado não estiver no buffer, o SQL Server faz uma
leitura física do dado em disco para o buffer pool.

A área de memória onde fica o Buffer Pool é configurada no SQL Server como 
Min Server Memory e Max Server Memory.


Configurando a memória no SQL SERVER.

   Quando instalamos o SQL SERVER, ele configura automáticamente a utilização da memória disponível
   no servidor. Ele tem as opções de "Max Server Memory" e "Min Server Memory"  que voce pode consultar
   com o seguinte comando:
*/

execute sp_configure 'show advanced options' , 1
go
reconfigure with override 

execute sp_configure 'min server memory (MB)'
execute sp_configure 'max server memory (MB)'

/*
   Na execução acima temos 1024Kb de memoria mínima e  2147483647KB(?) de memoria máxima.
   2 Tb de memória máxima? 

   Min Server Memory
   
   - Não significa memória mínima que o SQL SERVER utiliza.
   
   - Quando inicializamos o serviço do SQL Server, ele aloca inicialmente 128Kb e espera as atividades
     de inclusão, alteração e exclusão de dados pela aplicação. No decorrer da execução das consultas, 
     o SQL SERVER carrega os dados do disco e aloca na memória que ele reservou. Essa memória inicial 
     até atingir o valor de 'Min Server Memory' é do SQL SERVER e ele não entrega ao SO, se ele solicitar. 

     Quando a alocação ultrapassa esse valor mínimo, O SQL Server continua a alocar mais memória. Mas se 
     por algum motivo, o SO solicitar memória do SQL Server, o mesmo pode liberar a memória, mas até 
     atingir o limite mínimo.

   Max Server Memory
   
   - Não significa memória máxima que o SQL SERVER utiliza. 

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


execute sp_configure 'min server memory (MB)' , 512
go
reconfigure with override 
go
execute sp_configure 'max server memory (MB)' , 1536
go
reconfigure with override 

/*
Consultando a quantidade de páginas no Buffer Pool ocupada por cada
banco de dados.

Ref.: https://docs.microsoft.com/PT-BR/sql/relational-databases/system-dynamic-management-views/sys-dm-os-buffer-descriptors-transact-sql

*/

select * from sys.dm_os_buffer_descriptors


select db_name(database_id) as BancoDeDados, 
       (count(1) * 8192 ) / 1024 /1024 as nTamanhoPaginas 
  from sys.dm_os_buffer_descriptors
group by db_name(database_id)  
go

use eCommerce
go

select * from tCliente 










/*
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
*/
