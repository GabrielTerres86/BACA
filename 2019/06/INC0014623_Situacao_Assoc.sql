/* 
Solicitação: INC0014623
Objetivo   : Setar campo CRAPASS.CDSITDCT para tipo 4-encerrada por demissao na empresa.
             O cooperado já possui da de demissão mas continua com 
             situação 7-Processo de Demissão
Autor      : Jackson
*/

UPDATE CRAPASS SET CDSITDCT = 4 WHERE PROGRESS_RECID = 779275;
COMMIT;

