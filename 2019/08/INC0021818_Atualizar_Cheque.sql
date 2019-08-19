/* 
Solicita��o: INC0021818
Objetivo   : Atualizar 1  registro de CRAPFDC (folhas de cheque) do cheque 1012-0 da conta 1931750 (Viacredi), 
             para que N�O fique definido como "em cust�dia". A IF 422 (Banco Safra) fez a baixa de cust�dia desse cheque 
             e o processamento referente a essa baixa n�o foi realizado. Os cheques no Aimaro ainda aparece como "em cust�dia".  		
Autor: Edmar
*/

UPDATE CRAPFDC FDC
SET FDC.CDBANTIC = 0,
    FDC.CDAGETIC = 0,
    FDC.NRCTATIC = 0,
    FDC.DTLIBTIC = NULL,
    FDC.DTATUTIC = NULL
WHERE FDC.PROGRESS_RECID = 55071619;

COMMIT;
