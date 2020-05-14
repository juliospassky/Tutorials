/*
Um recurso da ferramenta SSMS, é a coleta de informações
referente a execução do comandos e a apresentação após o seu término
de execução. 

De forma semelhante ao SET STATISTICS, o recurso nativo do SMSS
Include Cliente Statistics, apresenta um conjunto de informações

*/

use DBDemo
go


select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

/*

Acionando o Client Statistics 

Com uma query aberta, vá até o menu principal e selecione Query.
Depois selecione Include Client Statistics.
Se preferir, Shift + Alt + S

Depois execute a query abaixo:
*/

use DBDemo
go
select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

/*
----------------------------------------------
Client Execution Time	18:47:42	
	
Query Profile Statistics	
------------------------		
  Number of INSERT, DELETE and UPDATE statements		
  Rows affected by INSERT, DELETE, or UPDATE statements	
  Number of SELECT statements 							
  Rows returned by SELECT statements	
  Number of transactions 	

Network Statistics	
------------------		
  Number of server roundtrips	
  TDS packets sent from client	
  TDS packets received from server	
  Bytes sent from client	
  Bytes received from server	

  * TDS - Tabular Data Stream - Protocolo de aplicativo usado para transferência
  de solicitações e respostas entre clientes e servidor de banco de dados.

Time Statistics	
---------------		
  Client processing time	
  Total execution time	
  Wait time on server replies	

As colunas Trialn (onde n é um número sequencial), representa a identificação
da execução e a colunva Average (Média) representa os valores médios das execuções.

*/


/*
Um exemplo utilizando 3 comandos 
*/

select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)
  go
  select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)
  go
select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

set nocount off


/*
Utilizandos SELECT , INSERT, UPDATE E DELETE 
*/

Begin transaction 

select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

update tCliente set mCredito = mCredito * 1.10
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

delete tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

insert into tCliente (iIDEstado, cNome, cCPF, cEmail, cCelular, dCadastro, 
dNascimento, cLogradouro, cCidade, cUF, cCEP, 
dDesativacao, mCredito
) Select top 10 iIDEstado, cNome, cCPF, cEmail, cCelular, dCadastro, 
dNascimento, cLogradouro, cCidade, cUF, cCEP, 
dDesativacao, mCredito
 from eCommerce.dbo.tCliente 
 
Rollback 





