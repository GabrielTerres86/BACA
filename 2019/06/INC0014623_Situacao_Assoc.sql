/* 
Solicita��o: INC0014623
Objetivo   : Setar campo CRAPASS.CDSITDCT para tipo 4-encerrada por demissao na empresa.
             O cooperado j� possui da de demiss�o mas continua com 
             situa��o 7-Processo de Demiss�o
Autor      : Jackson
*/

UPDATE CRAPASS SET CDSITDCT = 4 WHERE PROGRESS_RECID = 779275;
COMMIT;

