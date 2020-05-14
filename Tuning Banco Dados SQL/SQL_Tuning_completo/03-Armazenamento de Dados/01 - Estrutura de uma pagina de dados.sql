/*

PÁGINA DE DADOS - 8Kb ou 8192 bytes 

+-----------------------------------------------------------+
|                                                           |
|          CABEÇALHO (HEADER) DA PÁGINA - 96 BYTES          |
|                                                           |
+-----------------------------------------------------------+
|                                                           |
|                       ÁREA DE DADOS                       | 
|                                                           |
|         TAMANHO MÁXIMO DE UMA LINHA : 8060 BYTES          |
|                                                           |
|                                                           |
|                                                           |
+-----------------------------------------------------------+
| MATRIZ DOS SLOTS - 2 BYTES POR LINHA             |  |  |  |
+-----------------------------------------------------------+

Uma página de dados é exclusiva de um objeto de alocação de dados (Tabela ou Índice). 

Cabeçalho      : ID da Página, ID do Objeto, Tipo da Página, espaço live, etc....
Área de Dados  : Onde as linhas serão armazenadas. Alocadas em série, a partir do final do 
                 cabeçalho. Cada linha tem o limite de 8060 bytes. 
Matriz de Slot : Uma tabela que contém para cada linha, a posição que ele se inicia dentro da 
                 página. Também conhecida como tabela de deslocamento de linha ou offset row. 

Considerando a área de dados e matriz de slots, temos 8.096 bytes para armazenamento.

Ref.: 
https://docs.microsoft.com/pt-br/sql/relational-databases/pages-and-extents-architecture-guide

*/


/*
Set statistics io 


Quando ligado e uma instrução é executada, o SQL Server apresenta as estatísticas 
de acesso ao cache ou buffer ou a área de disco.

set statistics io on -- Ligar a apresentação
set statistics io off -- Desligar a apresentação

*/

set statistics io on

set statistics io off

/*
Quais dados são apresentados: 

Para cada tabela envolvida na instrução, é apresenta uma linha 
com as informações de estatísticas. São elas:

Table 'XXXXXXXX'		Nome da Tabela 
Scan count           Contagem de buscas para recuperar os dados.
logical reads			Qtd de Páginas acessadas no Buffer Pool (cache de dados).
physical reads       Qtd de Páginas acessadas do Disco.
read-ahead reads		Qtd de Páginas incluídas no Buffer Pool. Chamda leitura antecipada.

Outras informações contidas no resultado são referentes a dados LOB (Large Object ou 
tipo de dados para grandes objetos) como varchar(max) ou varbinary(max). 
São eles lob logical reads, lob physical reads e lob read-ahead reads. 
LOB serão tratados em uma seção específica.
*/

use DBDemo
go

Drop Table if exists DemoPage
go

Create Table DemoPage 
(
   Id int, 
   Titulo char(1000), 
   Observacao char(3000)
) 

/*
Cada linha da tabela terá cerca de 4004 bytes.
Vamos usar a função REPLICATE para criar uma sentença de caracters e incluir nas colunas.
*/

set statistics io on 

-- Primeira inclusão.

Insert into DemoPage (id, Titulo, Observacao) 
Values (1,replicate('A',1000),replicate('A',3000))

/*
Table 'DemoPage'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Scan count = 0, não fez busca para recuperar dados.
Logical Reads = 1, leu uma página para gravar os dados.
*/

Select * from DemoPage 

/*
Table 'DemoPage'. Scan count 1, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Scan count = 1, fez uma busca na tabela para recuperar dados.
Logical Reads = 1, leu uma página para gravar os dados.
*/


-- Segunda Inclusão 
Insert into DemoPage (id, Titulo, Observacao) 
Values (2,replicate('B',1000),replicate('B',3000))

/*
Table 'DemoPage'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Select * from DemoPage


-- Terceira Inclusão 
Insert into DemoPage (id, Titulo, Observacao) 
Values (3,replicate('C',1000),replicate('C',3000))


Select * from DemoPage

/*
id          titulo                                            
----------- --------------------------------------------------...
1           AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...
1           BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB...
1           CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC...

(3 rows affected)

Table 'DemoPage'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Select * 
  From DemoPage 
 where id = 1


Update DemoPage 
   set Titulo = replicate('a',1000)
 where id = 1 

/*
Para ler uma linha que está em uma página, ele leu 2 páginas de dados ?
*/


/*
*/

use DBDemo
go

set statistics io off


Drop table if exists tCliente 

/*
Cria uma tabela  
*/

Select iIDCliente, iIDEstado, cNome, cCPF, cEmail, 
       cCelular, dCadastro, dNascimento, cLogradouro, 
       cCidade, cUF, cCEP,  dDesativacao, mCredito 
  Into tCliente 
  From eCommerce.dbo.tCliente 

/*
Carregando uma linha da tabela clientes 
*/
set statistics io on

Select * 
  From tCliente
 Where iIDCliente = 1 

/*
Resultado :

iIDCliente  iIDEstado   cNome                 cCPF           cEmail                      cCelular    dCadastro  dNascimento cLogradouro        cCidade  cUF  cCEP     dDesativacao mCredito
----------- ----------- --------------------- -------------- --------------------------- ----------- ---------- ----------- ------------------ -------- ---- -------- ------------ ---------------------
1           1           Lara Moran Shepherd   1608122228599  eget.ipsum@loremsemper.com  67460 9064  2001-02-15 1971-09-18  524-4351 Ante Rd.  Itabuna  BA   43660387 NULL         100000,00

11Lara Moran Shepherd1608122228599eget.ipsum@loremsemper.com67460 90642001-02-151971-09-18524-4351 Ante Rd.ItabunaBA43660387NULL100000,00
----------------------------------------------------------------------------------------------------------------------------------------- 
138 bytes 

(1 row affected)

Table 'tCliente'. Scan count 1, logical reads 4016, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Logical Reads 4016, foram lidas 32 MB (?!?)

*/

Select * from tCliente

/*
(200000 rows affected)
Table 'tCliente'. Scan count 1, logical reads 4016, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Para ler um linha, logical reads 4016
Para ler todas as linhas, logical reads 4016 (???)
