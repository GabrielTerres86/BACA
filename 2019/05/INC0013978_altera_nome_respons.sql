/* 
Solicitação: INC0013978
Objetivo   : Alterar o valor do campo crapcrl.nmrespon para 
             o cooperado 178497 da cooperativa 5
             O nome possui caractere especial e deve ser corrigido
Autor      : Jackson
*/
UPDATE crapcrl
   SET nmrespon = 'GRAZIELA NETO PUCKER'
 WHERE nrctamen = 178497
   AND cdcooper = 5;

COMMIT;
/* 
SCRIPT DE ROLLBACK
Objetivo   : Volta valor do campo crapcrl.nmrespon para seu estado original
             para o cooperado 178497 da cooperativa 5
             Descomentar os códigos abaixo, caso necessite de rollback
*/
/*
UPDATE crapcrl
   SET nmrespon = 'GRAZIELA NETO PUCKER'
 WHERE nrctamen = 178497
   AND cdcooper = 5;

commit;
*/
