/*
Chave Primária e o Índice Clusterizado.

Chave Primária é uma coluna ou várias colunas de uma tabela que garante a unicidade da linha. 
Por boas práticas, 99% das tabelas devem possuir uma chave primária.

Como ela tem o papel de garantir a unicidade do dado, ela pode ser uma coluna do tipo inteiro (não tem relação
com os dados da aplicação) que também será utilizada para referências outras tabelas.

tAluno 
+--+------------------+-----------+----------+------------+
|Id|Nome              |Cpf        |Nascimento|Endereco    |
+--+------------------+-----------+----------+------------+
|1 |Joao da Silva     |12345670801|2001-06-27|Rua A       |
|92|Jose de Souza     |54875214801|1997-12-17|Rua Numero 2|
|83|Maria Aparecida   |45872155801|2003-03-18|Rua BBB     |
|44|Joaquim Gomes     |12548568801|1995-10-28|Rua XPTO    |
|5 |Manoel Cintra     |25425865801|2002-11-02|Rua Letra X |
|56|Joao da Silva     |52411585801|2003-01-15|Rua 456     |
|17|Jose da Silva     |63584558801|1998-02-23|Rua JKKK    |
|28|Patricio Porto    |52458554801|1994-09-30|Rua 434     |
|59|Manuela dos Montes|54114856801|1999-10-10|Rua B       |
|10|Joao da Silva     |54788565801|2001-06-14|Rua 999     |
+--+------------------+-----------+----------+------------+

Como boa prática, a chave primária pode ser um INTEIRO com numeração sequencial crescente.

Quando criamos em uma tabela uma constraint do tipo Primary Key, o SQL Server já cria um índice
Clusterizado Único para manter essa restrição.

Exemplos:

*/

use DBDemo
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente int not null identity(1,1) ,
   cNome varchar(100), 
   cCPF char(14),
   Constraint PKCliente Primary key 
   (
      iidCliente 
   )
)
go

sp_helpindex 'tCliente'
go
sp_pkeys 'tCliente'


insert into tCliente (cNome, cCPF)
select top 10000 cNome, cCPF from eCommerce.dbo.tCliente
go


set statistics io on
set statistics xml on

Select * from tCliente where iidcliente = 5000

set statistics io off
set statistics xml off

/*
Boa prática

- Criar a chave primária com índice Clusterizado.
- Selecionar a coluna que será a chave primária como sendo artificial, que não faz parte da
  regra de negócio da tabela e que não sofra modificação devido a mundanças das regras de negócio.
- A coluna deve ser númerica e do tipo inteiro. (mas não obrigatório).
- Atribua uma númeração automática, usando IDENTITY ou SEQUENCE.
- Evite ao máximo colocar duas colunas como chave primária.

*/


/*
Atenção, o fato de você criar um índice Clusterizado em uma tabela que não tem chave primária, 
a criação desse  índice não significa que a chave primária foi criada.
*/


use DBDemo
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente int not null identity(1,1) ,
   cNome varchar(100), 
   cCPF char(14)
)
go

Create Unique Clustered Index PKCliente on tCliente (iidcliente)
go

sp_helpindex 'tCliente'
go
sp_pkeys 'tCliente'


insert into tCliente (cNome, cCPF)
select top 10000 cNome, cCPF from eCommerce.dbo.tCliente
go


set statistics io on
set statistics xml on

Select * from tCliente where iidcliente = 5000

set statistics io off
set statistics xml off


