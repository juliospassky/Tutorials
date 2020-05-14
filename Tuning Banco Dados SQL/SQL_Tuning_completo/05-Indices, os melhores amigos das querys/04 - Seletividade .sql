/*
Seletivdade, Densidade e Cardinalidade 
*/


/*
Densidade - 
*/

set statistics io on 

select count(1) from tCliente
where cUF = 'SP' and cCidade = 'Maua'

select cNome from tCliente
where cCidade = 'Maua' and cUF = 'SP' 




Create Index idxLocal on tCliente (cUF, cCidade) with (drop_existing = on)

Create Index idxLocal on tCliente (cCidade, cUF)  with (drop_existing = on)

