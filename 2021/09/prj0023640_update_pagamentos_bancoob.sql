BEGIN

UPDATE crappro a 
   SET a.dscomprovante_parceiro = NULL
 WHERE EXISTS (SELECT 0
                 FROM craplft l
                WHERE a.cdcooper = l.cdcooper
                  AND a.nrdconta = l.nrdconta
                  AND a.dtmvtolt = l.dtmvtolt
                  AND a.cdtippro <> 13
                  AND a.nrseqaut = l.nrautdoc
                  AND l.idsicred IN (3553092,3553091));
                  
UPDATE tbconv_registro_remessa_pagfor a
   SET a.cdstatus_processamento = 4,
       a.dsprocessamento = 'ID Transação já utilizada',
       a.cdstatushttp = 400
 WHERE a.idsicredi IN (3553092,3553091);
 
 COMMIT;
END;
