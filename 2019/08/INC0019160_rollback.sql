/* 
Solicita��o: INC0019160 - BACKUP
Objetivo   : Voltar a situa��o de duas folhas de cheque ao estado original em rela��o ao incidente.
             Atualizar as colunas CRAPFDC.INCHEQUE e CRAPFDC.DTLIQCHQ de dois cheques, para que ambos voltem a ficar com normal e sem data de compensa��o.
Autor      : Edmar Oliveira
*/


UPDATE CRAPFDC FDC
SET FDC.INCHEQUE = 0,
    FDC.DTLIQCHQ = NULL  
WHERE FDC.CDCOOPER = 12
  AND FDC.NRDCONTA = 3700
  AND FDC.NRCHEQUE = 519
  AND FDC.PROGRESS_RECID = 52928694;
  
  
UPDATE CRAPFDC FDC
SET FDC.INCHEQUE = 0,
    FDC.DTLIQCHQ = NULL  
WHERE FDC.CDCOOPER = 12
  AND FDC.NRDCONTA = 62120
  AND FDC.NRCHEQUE = 56
  AND FDC.PROGRESS_RECID = 52104253;
  
COMMIT;  