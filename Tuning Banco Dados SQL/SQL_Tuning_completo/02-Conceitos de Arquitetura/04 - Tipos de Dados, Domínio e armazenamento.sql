/*
Tipos de Dados no SQL Server;
*/

/*
Quando criamos uma tabela, temos que definir as colunas onde os dados ficarão 
armazenados.

Essas colunas devem ser definidas com um conjunto de características que permite 
armazenar o dados correto, com o tamanho ideal e com as regras de restrições.

Nessa aula, vamos focar no tipo de dados, o seu domínio e principalmente quantos
bytes serão armazenados.

No final dessa aula, voce deve ser capaz de identificar corretamente o tamanho 
que será utilizado em cada coluna com o objetivo de armazenar o maior 
número possíveis de caracters em uma página de dados.
*/

use DBDemo
go

select * from vDataTypes
order by grupo 


/*
Para esse treinamento, vamos agrupas os tipos de dados em 
tamanho fixo e tamanho variável considerando o aspecto de armazenagem 
física dos dados. 

FIXO 
--------------------------------------------------------------------------

São os tipos de dados que armazenam o tamanho que foi declarado ou
definido para o tipo de dados, sem aumentar ou diminuir o número de bytes
de acordo com o dado inserido. 

Abaixo a relação dos tipo, domínio e dicas de onde utilizar. 

Exemplo:

INT         - Tipo de dados número exato, ele armazena sempre 4 bytes para representar 
              número interior entre -2.147.483.648 até 2.147.483.647.

              Muito utilizada para chave primária, permite identificar uma tabela com 
              mais de 2 bilhões de linhas (2.147.483.647 linhas).

              Evite usar para armazenar valores pequenos como IDADE. Utilize para armazenar
              dados que serão utilizados para efetuar algum cálculo ou operação matemática.
              Recomendado também em colunas altamente pesquisável. 

SMALLINT    - Dados de número exato, ele armazena sempre 2 bytes para representar números
              inteiros entre -32.768 até 32.767.

              Utilize para identificar linhas em tabelas que voce tenha certeza 
              que não ultrapasse de 30.000 linhas. Ou utilizado para contagem 
              ou armazenar pequenas quantidades.

TINYINT     - Tipo de dados de número exato, armazena 1 bytes para representar números
              inteiros positivos entre 0 e 255.

              Utilizados para pequenos valores, tipificar colunas, contagem pequenas ou
              número de dependentes.

BIGINT      - Tipo de dados de número exato, armazena 8 bytes para representar números
              entre -9.223.372.036.854.775.808 até 9.223.372.036.854.775.807. 
              
            
CHAR(n)     - Tipo de dado caracter que aceita 'n' bytes. O total de bytes
              declarado no tipo do dados será o mesmo para o armazenamento, independente
              da quantidade de caracteres associado. 
              Em um CHAR(10), por exemplo, mesmo que você inclua a palavra 
              'JOSE' (4 bytes) o SQL SERVER grava 10 bytes.
              
NCHAR(n)    - Tipo de dado UNICODE que aceita 'n' bytes, mas armazena 2*n bytes.
              ele utiliza 2 bytes para representar um caracter.
              A palavra 'JOSE' em um tipo NCHAR(10) será gravado com 20 bytes de armazenamento.
              O dados deve ser representado com o N maiúsculo na frente do litera.

*/

use DBDemo
go

go
drop table if exists Teste
go

Create Table Teste 
(
   Nome char(20),
   NomeInt nchar(20) 

)

insert into Teste (Nome, NomeInt) values ('JOSE DA SILVA',  'ホセ ダ シルヴァ')
insert into Teste (Nome, NomeInt) values ('JOSE DA SILVA', N'ホセ ダ シルヴァ')

select * from teste

/*            
DATE        - Tipo de dados data, aceita uma data no formato DD/MM/AAAA, armazena
              3 bytes com datas entre 01/01/0001 até 31/12/9999.

              Utilizado para registrar datas onde não precisamos registrar hora, minuto e segundos.
              Data de Nascimento, Data Fabricação, Data Previsão Entrega, etc... 

DATETIME    - Tipo de dados data e hora, aceita uma data no formato DD/MM/AAAA HH:MM:SS.SSS,
              armazena 8 bytes com data entre 01/01/1753 00:00:00.000 até 
              31/12/9999 23:59:59.997.
              Esse tipo de dados não é padrão ANSI. 

              Utilizado quando se deseja registrar datas com hora, minuto e segundos.
              Data da Entrega, Data do Pedido, Data Marcação de Ponto, etc... 

SMALLDATETIME  - Tipo de dados data e hora , aceita uma data no formato DD/MM/AAAA HH:MM:SS.SSS,
                 armazena 4 bytes com data entre 01/01/1900 00:00:00 até 
                 31/12/2079 23:59:00. Os segundos serão sempre zerados. 
                 Esse tipo de dados não é padrão ANSI. 

                 Utilizado para registrar datas com hora, minuto e com restrição do 
                 ano entre 1900 e 2079. Quando deseja registrar uma data do momento atual
                 sem precisão de segundos ou datas do passado depois do ano 1900.

DATETIME2(7) - Tipo de dados data e hora, aceita uma data no formato DD/MM/AAAA HH:MM:SS.SSSSSSS,
               com datas entre 01/01/0001 00:00:00 até 31/12/9999 23:59:59.9999999.
               Armazena 6 bytes quando utiliza até 2 digitos na fração do segundo (SS.SS)
               Armazena 7 bytes quando utiliza até 4 digitos na fração do segundo (SS.SSSS)
               Armazena 8 bytes quando utiliza até 7 digitos na fração do segundo (SS.SSSSSSS)
               Esse tipo de dados não é padrão ANSI. 

               Não vejo muito necessidade de uma precisão de 7 digitos na fração de segundos                   
               para amplicações comerciais. 

               Use DATETIME2(0), sem precisão de segundos, para registro de data e hora e armazenar
               6 bytes. 
*/

use DBDemo
go
drop table if exists tTesteData 
go 

Create Table tTesteData 
(
   Data1 date,
   Data2 datetime,
   Data3 smalldatetime,
   Data4 datetime2(2), 
   Data5 datetime2(7)
)

Insert into tTesteData (Data1,Data2,Data3,Data4,Data5) 
values (getdate(),getdate(),getdate(),getdate(),getdate())

select * from tTesteData

/*
Data1      Data2                   Data3                   Data4                       Data5
---------- ----------------------- ----------------------- --------------------------- ---------------------------
2018-03-14 2018-03-14 12:22:59.960 2018-03-14 12:23:00     2018-03-14 12:22:59.96      2018-03-14 12:22:59.9600000


DATE       DATETIME   SMALLDATETIME DATETIME(2) DATETIME(7)
---------- ---------- ------------- ----------  -----------
3 bytes    8 bytes    4 bytes       6 bytes     8 bytes 


TIME(n)     - Tipo de dado hora, aceita hora no formato HH:MM:SS.SSSSSSS,
              com horas entre 00:00:00 até 23:59:59.9999999
              até 2 dígitos de fração de segundos, 3 bytes de armazenamento,
              até 4 dígitos de fração de segundos, 4 bytes de armazenamento,
              até 7 dígitos de fração de segundos, 5 bytes de armazenamento.

              Esse tipo de dado não armazena horas aculumadas, como por exemplo
              32:35:05 de duração. 

              Geralmente voce armazena uma hora junto com um data para informar
              quando ocorreu um evento. 

              Se voce utiliza duas colunas ( uma DATE e outra TIME) voce consumirá
              6 bytes (DATE + TIME(2)) o que é equivalente ao DATETIME2(2).
                 
MONEY      - Tipo de dado númerico que representa um valor monetário entre 
             -922,337,203,685,477.5808 até 922.337.203.685.477,5807 (922 trilhões), 
             utilizando 8 bytes de armazenamento. 

             Pode ser utilizado para representar grandes quantias ou quando o armazenamento 
             na linha seja superior ao valor monetário de 214.748,3647.

SMALLMONEY - Tipo de dado númerico que representa um valor monetário entre 
             -214.748,3648 a 214.748,3647, utilizando 4 bytes de armazenamento. 

             Para representar valores unitários, valores de desconto ou acréscimo por exemplo.
             Se o valor for algo como acumulado ou totalizador, talvez o MONEY seja mais adequado. 

DECIMAL(p,s) - Tipo de dados númericos com precisão decimal. No formato (p,s), o 'p' representa o 
               total máximo de dígitos (incluíndo a escala) que serão armazenados e o 's' representa 
               a escala que é o total de digitos a direita do ponto decimal.
               Até 9 dígitos na precisão, 5 bytes de armazenamento,
               até 19 dígitos na precisão, 9 bytes de armazenamento,
               até 28 dígitos na precisão, 13 bytes de armazenamento,
               até 38 dígitos na precisão, 17 bytes de armazenamento.
               NUMERIC é igual ao DECIMAL.

               Utilize o DECIMAL para representar valores com casa decimais de tamanho fixo. Dados
               como quantidade média, distância ou até mesmo tempo. 

               No caso de valores monetários, temos um linha muito tênue entre usar DECIMAL ou 
               MONEY/SMALLMONEY.

               Exemplos:

               Para valores até 214748,3647 voce pode usar o SMALLMONEY que armanzena 4 bytes contra
               qual precisão ou escala do DECIMAL. 

               Se voce deseja usar valor 2 casas decimais e acima do valor 214748,3647, então
               voce pode usar o DECIMAL(9,2) que tem uma faixa próxima a 10 milhões e voce 
               armazena 5 bytes.

               Para valores acima de 10 milhões e usando 2 casas decimais para o tipo DECIMAL, voce
               precisa de 9 bytes de armazenamento. Neste caso compensa utilizar o MONEY. 


VARIÁVEL
--------------------------------------------------------------------------
Tipos de dados que armazena a quantiadde de bytes inserido até o limite máximo
declarado. 

Exemplo: 

VARCHAR(n)   - Tipo de dados caracter que aceita no máximo n bytes. Se voce incluir
               a palavra 'JOSE' em um VARCHAR(10) , o SQL SERVER armazena 6 bytes. 
               O SQL Server já calcula 2 bytes a mais no armazenamento para 
               considerar o cálculo para gravar e recuperar os dados. 

NVARCHAR(n)  - Tipo de dados caracter UNICODE que aceita no máximo n bytes e grava 
               2 bytes para cada caracter informado e acrescenta mais 2 bytes 
               para considerar o cálculo para gravar e recuperar os dados. 
               Se voce incluir a palavra 'JOSE' em NVARCHAR(10)o SQL Server 
               armazena 10 bytes (2 bytes para cada caracter, então temos 
               8 bytes mais 2 bytes de calculo). Para esse tipo de dados, 
               voce deve representa com o N maiusculo na frente do literal. 

Tipos de dados UNICODE somente deve ser utilizados se realmente voce precisa
gravar algum caracter com o código UNICODE acima de 255. 

Código de caracter de 0 até 255 são representados com 1 bytes.
Código de caracter de 256 ate 65554 são representados com 2 bytes. 


Ref.: https://unicode-table.com/pt/
      https://unicode-table.com/pt/#30DB

*/

declare @Nome1 varchar(10) = 'Jose'
select len(@Nome1) , datalength(@Nome1)
 
declare @Nome2 nvarchar(10) = N'Jose'
select len(@Nome2) , datalength(@Nome2)

go


use DBDemo
go

Create Table tTelefones 
(
   Telefone1 VARCHAR(10), 
   Telefone2 CHAR(10), 
   Telefone3 NVARCHAR(10), 
   Telefone4 NCHAR(10), 
)

insert into tTelefones (Telefone1,Telefone2,Telefone3,Telefone4)
values ('27999999','27999999','27999999','27999999')

select * from tTelefones

/*
Telefone1  Telefone2  Telefone3  Telefone4
---------- ---------- ---------- ----------
27999999   27999999   27999999   27999999  

Telefone1  Telefone2  Telefone3  Telefone4
---------- ---------- ---------- ----------
10 bytes   10 bytes   18 bytes   16 bytes 

Nesse cenário, qual tipo de dados utilizar?  

Eu utilizaria o CHAR(10).

E se no lugar do CHAR, utilizar um DECIMAL ? 

*/

drop table if exists tTelefones
go 

Create Table tTelefones 
(
   Telefone1 INT,
   Telefone2 DECIMAL(8)
)

Insert into tTelefones (Telefone1, Telefone2) values (27999999,27999999)

Select * from tTelefones

/*
Telefone1   Telefone2
----------- ---------------------------------------
27999999    27999999

Telefone1   Telefone2
----------- ---------------------------------------
4 bytes     5 bytes 

Então quer dizer que para guardar um número de telefone de 8 dígitos,
podemos usar 4 bytes ao invés de 10 bytes? 

Então !!! 

O assunto gravar dados que contém números, mas não usamos em cálculos como 
CPF, RG, CNPJ, CEP, TELEFONE em colunas do tipo CHAR ou VARCHAR?

Ref.: https://social.msdn.microsoft.com/Forums/sqlserver/pt-BR/506397e7-2d59-46cd-9c68-7876efadc74f/campo-cpf-cnpj-codigointernto-como-int-ou-charn?forum=520

Veja alguns comentários para ajudar a escolher a melhor forma de armazenar, 
garantindo a consistência dos dados.

- Esses dados, em alguns casos devem possuir zeros esquerda, que gravando em colunas
  INT, serão perdidos. Voce terá que programar a recuperação dos dados, incluíndo os zeros
  iniciais.

- Dependendo da aplicação, as vezes será necessário gravar os dados com as suas máscaras quando aplicado.
  CPF      - 011.154.225-55
  CNPJ     - 944.095.095/0001-44
  CEP      - 11000-000
  TELEFONE - 9.9543-3433

*/

Declare @cpf bigint = 01115422555
Select @cpf

Declare @cnpj bigint = 944095095000144
Select @cnpj

Declare @cep int = 11000000
Select @cep


/*
Recomendações finais.

- Não use NCHAR ou NVARCHAR, a não ser que voce tenha certeza que precisa armazenar 
  caracters que ocupam 2 bytes. 

- Chave Primária = INT 

- 

Agora vamos entender como a página de dados funciona é por que voce deve escolher corretamente os
tipos e tamanho dos dados. 


*/


/*
Algumas boas práticas 

1. Não use NCHAR ou NVARCHAR.

2. Utiliza INT para CHAVE PRIMARIA das tabelas, armazenar valores inteiros acima de 32.767.
   Lembre-se que mesmo gravando valores pequenos como 10, 50 ou 100, o armazenamento será de 
   4 bytes. 

3. Se a tabela armazenará no máximo 30.000 linhas e se voce tem controle dessa quantidade
utilize SMALLINT como CHAVE PRIMARIA.

4. Pequenas tabelas para armazenar categorias, grupos ou tipificação, veja a possibilidade 
   de usar TINYINT para identificacação das linhas.

4. Utilize BIGINT somente em caso de real necessidade. 

5. Utilizar VARCHAR somente para colunas com variações grandes de dados e com tamanhos grandes.

   VARCHAR(10) será armazenado 12 bytes, 20% do espaço é de controle.
   Se voce utilizar esse tipo de dados para cadastrar o telefone fixo sem DDD, por exemplo:
      
   27999999 --> São 8 bytes

   Tipo           Armazenamento 
   -------------- -------------
   VARCHAR(10)               10 
   CHAR(10)                  10   
   NCHAR(10)                 16
   NVARCHAR(10)              18

6. Analise o uso de CHAR ou INT para representar números. 

7. Armazenar valores que são resultado de cálculos de outras colunas, somente se voce utiliza
   essa coluna como pesquisa.

   Create Table ItemPedido
   (
      IdItem int,
      idProduto int ,
      nQuantidade smallint ,
      nPrecoUnitario smallmoney,
      nPrecoTotal smallmoney
   )

   A coluna nPrecoTotal será obtida com a operação nQuantidade * nPrecoUnitario. Então não
   precisa armazenar esse dados na coluna nPrecoTotal.

   Create Table ItemPedido
   (
      IdItem int,
      idProduto int ,
      nQuantidade smallint ,
      nPrecoUnitario smallmoney,
      nPrecoTotal as nQuantidade * nPrecoUnitario
   )

8. Utilize DATE quando deseja registrar um evento com dia mes e ano. 
   Exemplo: Data de construção, Data de nascimento



*/

;
with cteTamanho as  (
    select 1 as nTamanho , 0 as anc 
    union all 
    select nTamanho+1 as nTamanho  , 1 as anc 
    from cteTamanho
    where nTamanho < 100 
)
select 'VARCHAR('+ cast(nTamanho as varchar(3))+')' , nTamanho + 2   from cteTamanho 

      




select max(DATALENGTH(cNome)), avg(DATALENGTH(cNome)) from tCliente_ComVarChar

