/* 
Solicitação: INC0013718
Objetivo   : Setar campo CRAPASS.CDSITDCT para tipo 4-encerrada por demissao na empresa.
             O cooperado já possui da de demissão mas continua com 
             situação 7-Processo de Demissão
Autor      : Jackson
*/

UPDATE CRAPASS SET CDSITDCT = 4 WHERE PROGRESS_RECID = 862378;
COMMIT;

/* 
SCRIPT DE ROLLBACK
Objetivo   : Volta o registro de cooperado para a situação: 7-Processo de Demissão
             Descomentar os códigos abaixo, caso necessite de rollback
*/
/*
UPDATE CRAPASS SET CDSITDCT = 7 WHERE PROGRESS_RECID = 862378;
COMMIT;
*/

