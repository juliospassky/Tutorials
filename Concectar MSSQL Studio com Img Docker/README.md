
# Concectar MSSQL Studio com Img Docker

## Docker e Kitmatic
 - No Kitmatic adicione a imagem mssql-server-linux
 - Adicione as variáveis de ambiente:
   - MSSQL_SA_PASSWORD : a1s2d3f4#
   - ACCEPT_EULA : Y
 - Start na imagem
 
## Sql Management Studio 
 - Nome Servidor : localhost,32773 (Verificar a porta em HostName/Ports)
 
![Image of Config](https://github.com/juliocsoft/Tutorials/blob/master/Concectar%20MSSQL%20Studio%20com%20Img%20Docker/img.png)
