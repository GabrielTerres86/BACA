/* 
Solicitação: INC0021818
Objetivo   : Atualizar 1  registro de CRAPFDC (folhas de cheque) do cheque 1012-0 da conta 1931750 (Viacredi), 
             para que NÃO fique definido como "em custódia". A IF 422 (Banco Safra) fez a baixa de custódia desse cheque 
             e o processamento referente a essa baixa não foi realizado. Os cheques no Aimaro ainda aparece como "em custódia".  		
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
