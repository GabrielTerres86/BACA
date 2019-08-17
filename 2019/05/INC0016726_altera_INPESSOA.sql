/* 
Solicitação: INC0016726 
Objetivo   : Setar campo INPESSOA para tipo 3-Jurídico para a conta 8579997 da Cooperativa 1.
Autor      : Jackson
*/
update CRAPASS set INPESSOA = 3 where cdcooper = 1 and nrdconta = 8579997;

COMMIT;





