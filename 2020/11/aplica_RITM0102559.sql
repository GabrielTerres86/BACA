/*
   IMPLEMENTAR
   RITM0102559 - Script para incluir data de liberação/cancelamento de cheques em contas situação 4
*/
UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 6712324
   AND fdc.progress_recid <= 58720318
   AND fdc.cdcooper = 1
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 26555032
   AND fdc.progress_recid <= 55953957
   AND fdc.cdcooper = 2
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 28408453
   AND fdc.progress_recid <= 36500509
   AND fdc.cdcooper = 4
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 29098176
   AND fdc.progress_recid <= 46935460
   AND fdc.cdcooper = 5
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 29364556
   AND fdc.progress_recid <= 52804046
   AND fdc.cdcooper = 6
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 30020943
   AND fdc.progress_recid <= 55826582
   AND fdc.cdcooper = 7
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 30441701
   AND fdc.progress_recid <= 43695155
   AND fdc.cdcooper = 8
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 30853259
   AND fdc.progress_recid <= 54568274
   AND fdc.cdcooper = 9
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 31670940
   AND fdc.progress_recid <= 46807463
   AND fdc.cdcooper = 10
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 31867256
   AND fdc.progress_recid <= 58046777
   AND fdc.cdcooper = 11
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 32306867
   AND fdc.progress_recid <= 46178724
   AND fdc.cdcooper = 12
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 32502193
   AND fdc.progress_recid <= 51637373
   AND fdc.cdcooper = 13
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 32806976
   AND fdc.progress_recid <= 53821741
   AND fdc.cdcooper = 14
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 33241342
   AND fdc.progress_recid <= 33250154
   AND fdc.cdcooper = 15
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 33258646
   AND fdc.progress_recid <= 57287197
   AND fdc.cdcooper = 16
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE dtliqchq IS NULL /*Data de liquidacao do cheque.*/
   AND fdc.incheque = 0 /*Folha sem uso*/
   AND fdc.progress_recid >= 43694627
   AND fdc.progress_recid <= 43694656
   AND fdc.cdcooper = 17
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

COMMIT;


