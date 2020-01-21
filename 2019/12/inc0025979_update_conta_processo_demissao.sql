/* 
Solicitação: INC0025979
Objetivo   : Setar campo CRAPASS.CDSITDCT para tipo 7-Em processo de demissão.
Autor      : Carlos Henrique
*/
UPDATE CRAPASS SET CDSITDCT = 7 WHERE PROGRESS_RECID = 729783;
COMMIT;
