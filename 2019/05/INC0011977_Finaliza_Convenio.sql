/* 
Solicitação: INC0011977
Objetivo   : Alterar o valor do campo crapatr.dtfimatr para a conta 9293701 da cooperativa 1.
             Sistema não está apresentando na tela AUTORI o convenio para que o mesmo possa ser finalizado.
Autor      : Jackson
*/
UPDATE crapatr
   SET dtfimatr = trunc(sysdate)
 WHERE dtfimatr IS NULL
   and progress_recid = 791526;
   
COMMIT;
/* 
SCRIPT DE ROLLBACK
Objetivo   : Volta valor do campo crapatr.dtfimatr para seu estado original
*/
/*
UPDATE crapatr
   SET dtfimatr = NULL
 WHERE dtfimatr IS NOT NULL
   and progress_recid = 791526;
   
COMMIT;
*/







   
   
   
   
   
