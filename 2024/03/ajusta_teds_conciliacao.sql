BEGIN

  UPDATE tbfin_recursos_movimento ted
   SET ted.dtconciliacao = SYSDATE
 WHERE ted.rowid IN
       (SELECT ted.rowid
          FROM tbfin_recursos_movimento ted
         INNER JOIN crapban banco
            ON (ted.nrispbif = banco.nrispbif AND
               banco.cdbccxlt = decode(ted.nrispbif, 0, 1, banco.cdbccxlt))
          LEFT JOIN crapagb agencia
            ON (agencia.cddbanco = banco.cdbccxlt AND cdagenci_debitada = agencia.cdageban)
          LEFT JOIN crapcaf caf
            ON (caf.cdcidade = agencia.cdcidade)
         WHERE ted.dsdebcre = 'C'
           AND TED.INDEVTED_MOTIVO = 0
           AND ted.cdhistor IN (2622, 2917, 3005)
           AND ted.dtconciliacao IS NULL
           AND banco.cdbccxlt = 237
           AND agencia.cdageban = 1272
           AND ted.dsconta_debitada = 19186);
    
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
