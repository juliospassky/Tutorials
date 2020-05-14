/*
Desativar o SET NOCOUNT ON 

- Quando executamos uma instrução INSERT, UPDATE, DELETE, MERGE ou um procedimento 
  armazenado, as vezes recebemos a mensagem:

  (XX rows affected)

  que indica o total de linhas processadas pelos comandos.

- Toda a execução de comandos que afetam um determinado número de linhas de uma tabela,
  sempre retornam para a sessão ativa ( ou para a conexão da aplicação) o total dessas linhas.

- Voce deve utilizar o SET NOCOUNT ON na fase de programação para evitar esse trânsito de dados
  na rede e, de alguma forma, reduzir o tempo de processamento das instruções. 

- De acordo com site da Microsoft. 
  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/statements/set-nocount-transact-sql?view=sql-server-2017

  "SET NOCOUNT ON evita o envio de mensagens DONE_IN_PROC ao cliente para cada instrução em 
   um procedimento armazenado. Para procedimentos armazenados que contêm várias instruções 
   que não retornam muitos dados reais, ou para procedimentos que contêm loops Transact-SQL, 
   configurar SET NOCOUNT como ON pode fornecer um aumento significativo no desempenho, 
   porque o tráfego de rede é reduzido consideravelmente."


*/


/*
Configurando o SET NOCOUNT em store procedure. 
Essa configuração somente tera efeito para a procedure.
Ela não afeta a configuração da conexão atual. 

*/
use eCommerce
go

Create or Alter Procedure stp_AtualizaPrecoA
@iidProduto int ,
@nPreco smallmoney
as
begin

   Update tProduto
      Set nPreco = @nPreco
    Where iIDProduto = @iidProduto

end
go

Select top 10 * from tProduto 
go
execute stp_AtualizaPrecoA 1, 383.00
go 


Create or Alter Procedure stp_AtualizaPrecoB
@iidProduto int ,
@nPreco smallmoney
as
begin

   Set nocount on

   Update tProduto
      Set nPreco = @nPreco
    Where iIDProduto = @iidProduto

end
go


execute stp_AtualizaPrecoB 1, 313.00
go 

/*
Ativar o Include Client Statistics 
*/

execute stp_AtualizaPrecoA 1, 383.00
go 100

execute stp_AtualizaPrecoB 1, 383.00
go 100

/*
Com exemplos de querys mais complexas 
*/

/*------------------------------------------------------------------------------
stp_IncluirItensPedido 
- Não pode incluir o mesmo item duas vezes para o mesmo pedido.
---------------------------------------------------------------------------------*/

Create or Alter Procedure stp_IncluirItensPedido 
@iIDMovimento int 
with recompile
as
Begin 

   set nocount on   

   declare @tTMPCliente table (iidcliente int, mCredito money)
   declare @nItensPorPedido int = (rand()*15)+1 

   declare @tQuantidade table (iidProduto int default  (rand()*100000)+1,
                               nQuantidade int default (rand()*100)+1,
							   nDesconto smallmoney default rand()*10)

   while @nItensPorPedido+10 >= (select count(1) from @tQuantidade)
      insert into @tQuantidade default values
   
   
   Insert into tItemMovimento 
   (  iIDMovimento, 
      iIDProduto, 
      nQuantidade, 
      mPreco,
      mDesconto, 
      mICMS, 
      nQtdEmbalagem
   )
   Select top (@nItensPorPedido) 
          @iIDMovimento ,
          Qtd.iidProduto,
          Qtd.nQuantidade,
          tProduto.nPreco,
          Qtd.nDesconto,
          0,
          0
      From tProduto 
	  join @tQuantidade as Qtd on tProduto.iidproduto =Qtd.iidProduto
      where tProduto.nEstoque > 0
      And not exists (Select top 1 1 
                        From tItemMovimento 
                        Where iIDMovimento = @iIDMovimento 
                           and iIDProduto = tProduto.iIDProduto);
   
   with ctePedido as (
        Select @iIDMovimento as iIDMovimento , 
               sum(mPreco) as mPreco , 
               sum(mDesconto) as mDEsconto
        From tItemMovimento
        where iidMovimento  = @iIDMovimento
   )
   Update tMovimento 
      set mValor = i.mPreco , 
          mDesconto = i.mDesconto 
   output deleted.iIDCliente , 
          inserted.mValor-inserted.mDesconto 
     into @tTMPCliente
     From tMovimento m join ctePedido i
       on m.iIDMovimento = i.iIDMovimento
    where m.iIDMovimento = @iIDMovimento

    Update tcliente 
	   Set mCredito = tCliente.mCredito - t.mCredito
      From tCliente 
	  Join @tTMPCliente as t
        on tCliente.iIDCliente = t.iidcliente;

	update tProduto set nEstoque = nEstoque - Qtd.nQuantidade 
      From tProduto 
	  Join @tQuantidade as Qtd
	    on tProduto.iIDProduto = Qtd.iidProduto 

End 
/*
Fim de stp_IncluirItensPedido 
*/

select top 1 * from tMovimento order by iIDMovimento desc 

stp_IncluirItensPedido 355036
go 100 


/*
Network Statistics			
  Number of server roundtrips 	   2		   2.0000
  TDS packets sent from client	   2		   2.0000
  TDS packets received from server	2		   2.0000
  Bytes sent from client	         146		146.0000
  Bytes received from server	      810		810.0000
*/

/*
Network Statistics			
  Number of server roundtrips    	2		   2.0000
  TDS packets sent from client	   2		   2.0000
  TDS packets received from server	2		   2.0000
  Bytes sent from client	         146		146.0000
  Bytes received from server	      82		   82.0000
*/



stp_IncluirItensPedido 1

/*
Network Statistics			
  Number of server roundtrips	      2		2.0000
  TDS packets sent from client	   2		2.0000
  TDS packets received from server	2		2.0000
  Bytes sent from client	         136	136.0000
  Bytes received from server	      82		82.0000
*/

/*
Network Statistics			
  Number of server roundtrips	      2		2.0000
  TDS packets sent from client	   2		2.0000
  TDS packets received from server	2		2.0000
  Bytes sent from client	         136		136.0000
  Bytes received from server	      576		576.0000
*/


/*
Network Statistics			
  Number of server roundtrips	      101		101.0000
  TDS packets sent from client	   101		101.0000
  TDS packets received from server	101		101.0000
  Bytes sent from client	         9258		9258.0000
  Bytes received from server	      61087		61087.0000

Network Statistics			
  Number of server roundtrips	      101		101.0000
  TDS packets sent from client	   101		101.0000
  TDS packets received from server	101		101.0000
  Bytes sent from client	         9258		9258.0000
  Bytes received from server	      4537		4537.0000
*/
