Creditos [SQL SERVER no máximo desempenho. Aprenda SQL TUNING!](https://www.udemy.com/course/tuning-em-t-sql/)

# Performatização de Queries
## Search Argument (SARG)
SARG é a forma correta de montar a query para performar a consulta.

Deve-se montar a estrutura < Coluna > < Operador > < Valor >. A < Coluna > da clausula não deve conter operação.

Exemplo SARG e NoSARG, ambas trazem o mesmo resultado, no entanto a SARG é a performática
```sql

--Exemplo 1
--SARG
Select iidCliente, cNome, cCPF, dCadastro From tCliente 
 Where dCadastro > '2018-01-01'

--NoSARG
Select iidCliente, cNome, cCPF, dCadastro From tCliente 
 Where cast(dCadastro as datetime) > '2018-01-01'

--Exemplo 2
--SARG
Select iIDCliente, cNome, cCPF  from tCliente 
Where cNome like 'Wallace%'

--NoSARG
Select iIDCliente, cNome, cCPF  from tCliente 
Where  substring(cNome, 1,7) = 'Wallace'
```
## Conversão Inplicita
A conversão implicita é um cast feito pela query para comparar a expressão. Por exemplo, uma coluna definida como VARCHAR sendo comparada com um INT. Esse tipo de conversão pode resultar em um index scan na tabela toda.
```sql
Create Table tCliente (
   iidCliente smallint not null identity(1,1) ,
   cCPF char(14),
   Constraint PKCliente Primary key ( iidCliente))

Select * from tCliente
where cCPF = 71375968870  
```
Deve-se sempre atentar na comparação com o mesmo tipo de dado.

## No Count
Quando executa-se uma instrução INSERT, UPDATE, DELETE, MERGE ou um procedimento armazenado (SP), recebemos a mensagem:

  (XX rows affected)
  
  Em um ambiente de produção que essa informação não seja necessária, as queries ganharão performance no trafego de rede.
  Para desabilitar essa informação usa-se a instrução: Set nocount on
  
```sql
Create or Alter Procedure stp_AtualizaPrecoB
@iidProduto int, @nPreco smallmoney as
begin
   Set nocount on
   Update tProduto
      Set nPreco = @nPreco
    Where iIDProduto = @iidProduto
end
go
```

## Não validar os dados antes de atualizá-los

Dado o seguinte cenário: Deve-se criar uma procedure para atualizar o crédito do cliente.
Receber o id do cliente e o valor do crédito. Voce deve validar se o cliente existe. Se sim, realizar alteração do clientes,
substituíndo o credito atual pelo novo. Se não, emitir uma mensagem de aviso para a aplicação.

Exemplo ruim
```sql
Create or Alter Procedure stp_AlteraClienteCredito
@iidCliente int,
@mCredito money as
Begin 
    set nocount on
    
    declare @lClienteExiste int = 0 -- Assume o valor zero 

    Select @lClienteExiste = iidcliente 
      From tCliente 
     Where iIDCliente = @iidCliente     
    if @lClienteExiste <> 0
       update tCliente 
          set mCredito = @mCredito 
        where iIDCliente = @iidCliente
    else 
       raiserror('Cliente %d não existe', 16,1,@iidcliente)    
    Return @lClienteExiste
End 
go
```

Exemplo mekhor, sem fazer  a verificação, apenas realizar o UPDATE
```sql
Create or Alter Procedure stp_AlteraClienteCredito
@iidCliente int,
@mCredito money as
Begin

    Set nocount on 

    Declare @lClienteExiste int = 0 -- Assume o valor zero 

    Update tCliente 
       Set mCredito = @mCredito 
     Where iIDCliente = @iidCliente
    
    Select @lClienteExiste = @@ROWCOUNT

    If @lClienteExiste = 0    
       Raiserror('Cliente %d não existe', 16,1,@iidcliente)
     
    Return @lClienteExiste
End 
go
```
