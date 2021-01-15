
 UPDATE crapcrb c
    SET c.dtcancel = TRUNC(SYSDATE),
        c.dsmotcan = 'Cancelamento manual devido a problemas FTP - INC0049114'    
 WHERE EXISTS (
        SELECT crb.idtpreme
               ,crb.dtmvtolt
               ,pbc.idtpsoli
               ,crb.*
          FROM crapcrb crb
               ,crappbc pbc
         WHERE 1 = 1 --crb.idtpreme = nvl(&pr_idtpreme,crb.idtpreme)
           AND crb.idtpreme IN ('NOVAVIDAED', 'NOVAVIDATE', 'UNIT4END', 'UNIT4TEL')
           --ND crb.dtmvtolt = nvl(&pr_dtmvtolt, crb.dtmvtolt)
           AND crb.idtpreme = pbc.idtpreme
           AND pbc.idtpreme <> 'SMSDEBAUT' 
           AND pbc.flgativo = 1 
           AND crb.dtcancel IS NULL 
           AND c.rowid = crb.rowid
              -- Sem o arquivo da preparação ou Envio
           AND NOT EXISTS (SELECT 1
                  FROM craparb arb
                 WHERE crb.idtpreme = arb.idtpreme
                   AND crb.dtmvtolt = arb.dtmvtolt
                   AND arb.cdestarq IN (2, 3)) --> Preparação ou Envio
        );
 COMMIT;        
