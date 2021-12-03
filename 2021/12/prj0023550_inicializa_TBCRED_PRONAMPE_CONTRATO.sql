BEGIN
  INSERT INTO credito.tbcred_pronampe_contrato
    (cdcooper
    ,nrdconta
    ,nrcontrato)
    (SELECT epr.cdcooper
           ,epr.nrdconta
           ,epr.nrctremp
       FROM cecred.crapepr epr
      WHERE epr.cdlcremp = 2600
        AND NOT EXISTS (SELECT 1
               FROM credito.tbcred_pronampe_contrato pnp
              WHERE pnp.cdcooper = epr.cdcooper
                AND pnp.nrdconta = epr.nrdconta
                AND pnp.nrcontrato = epr.nrctremp));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;         
  