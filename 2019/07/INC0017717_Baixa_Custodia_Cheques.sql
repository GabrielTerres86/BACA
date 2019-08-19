/* 
Solicitação: INC0017177
Objetivo   : Atualizar os registros de CRAPFDC (folhas de cheque) dos cheques 1445 a 1449 da conta 90264460 (Viacredi), 
             para que NÃO fiquem definidos como "em custódia". A IF 237 fez a baixa de custódia desses cheques 
             e o processamento referente a essas baixas não foi realizado. Os cheques no Aimaro ainda aparecem como "em custódia".  
Tratando casos de caracteres inválidos nos emails.		
Autor: Edmar
*/


-- Cheque 1445/1
UPDATE CRAPFDC FDC
SET FDC.CDBANTIC = 0,
    FDC.CDAGETIC = 0,
    FDC.NRCTATIC = 0,
    FDC.DTLIBTIC = NULL,
    FDC.DTATUTIC = NULL
WHERE FDC.PROGRESS_RECID = 53806610;      

-- Cheque 1446/0
UPDATE CRAPFDC FDC
SET FDC.CDBANTIC = 0,
    FDC.CDAGETIC = 0,
    FDC.NRCTATIC = 0,
    FDC.DTLIBTIC = NULL,
    FDC.DTATUTIC = NULL
WHERE FDC.PROGRESS_RECID = 53806611;      

-- Cheque 1447/8
UPDATE CRAPFDC FDC
SET FDC.CDBANTIC = 0,
    FDC.CDAGETIC = 0,
    FDC.NRCTATIC = 0,
    FDC.DTLIBTIC = NULL,
    FDC.DTATUTIC = NULL
WHERE FDC.PROGRESS_RECID = 53806612; 

-- Cheque 1448/6
UPDATE CRAPFDC FDC
SET FDC.CDBANTIC = 0,
    FDC.CDAGETIC = 0,
    FDC.NRCTATIC = 0,
    FDC.DTLIBTIC = NULL,
    FDC.DTATUTIC = NULL
WHERE FDC.PROGRESS_RECID = 53806613; 

-- Cheque 1449/4
UPDATE CRAPFDC FDC
SET FDC.CDBANTIC = 0,
    FDC.CDAGETIC = 0,
    FDC.NRCTATIC = 0,
    FDC.DTLIBTIC = NULL,
    FDC.DTATUTIC = NULL
WHERE FDC.PROGRESS_RECID = 53806614; 

COMMIT;