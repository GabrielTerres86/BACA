/* 
Solicitação: INC0014267
Objetivo   : Setar campo INPESSOA para tipo 2-Administrativo.
Autor      : Jackson
*/   
update CRAPASS set INPESSOA = 2 where cdcooper = 3 and nrdconta = 116;
update CRAPASS set INPESSOA = 2 where cdcooper = 3 and nrdconta = 124;
  
COMMIT;
