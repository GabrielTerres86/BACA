/* 
Solicita��o: INC0013718
Objetivo   : Setar campo CRAPASS.CDSITDCT para tipo 4-encerrada por demissao na empresa.
             O cooperado j� possui da de demiss�o mas continua com 
             situa��o 7-Processo de Demiss�o
Autor      : Jackson
*/

UPDATE CRAPASS SET CDSITDCT = 4 WHERE PROGRESS_RECID = 862378;
COMMIT;

/* 
SCRIPT DE ROLLBACK
Objetivo   : Volta o registro de cooperado para a situa��o: 7-Processo de Demiss�o
             Descomentar os c�digos abaixo, caso necessite de rollback
*/
/*
UPDATE CRAPASS SET CDSITDCT = 7 WHERE PROGRESS_RECID = 862378;
COMMIT;
*/

