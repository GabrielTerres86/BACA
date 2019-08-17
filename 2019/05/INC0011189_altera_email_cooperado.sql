/* 
Solicitação: INC0011189
Objetivo   : Corrigir o valor do campo crapcem.dsdemail para 
             o cooperado 8226814 da cooperativa 1
             Seu respectivo progress_recid é 632623
Autor      : Jackson
*/
UPDATE crapcem
   SET dsdemail = 'ruthhl@outlook.com'
 WHERE progress_recid = 632623;

commit;
/* 
SCRIPT DE ROLLBACK
Objetivo   : Volta valor do campo crapcem.dsdemail para seu estado original
             para o cooperado 8226814 da cooperativa 1
             Seu respectivo progress_recid é 632623
             Descomentar os códigos abaixo, caso necessite de rollback
*/
/*
UPDATE crapcem
   SET dsdemail = 'ruthhl@outlook.com'
 WHERE progress_recid = 632623;

commit;
*/
