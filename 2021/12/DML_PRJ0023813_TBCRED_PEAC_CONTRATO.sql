BEGIN
  INSERT INTO credito.tbcred_peac_contrato
    (cdcooper
    ,nrdconta
    ,nrcontrato
	,vlcontrato
    ,idcontrato)
    (SELECT epr.cdcooper
           ,epr.nrdconta
           ,epr.nrctremp
		   ,vlemprst
           ,epr.progress_recid
       FROM cecred.crapepr epr
      WHERE epr.cdlcremp in (5600, 4600, 508)
        AND NOT EXISTS (SELECT 1
               FROM credito.tbcred_peac_contrato pnp
              WHERE pnp.cdcooper = epr.cdcooper
                AND pnp.nrdconta = epr.nrdconta
                AND pnp.nrcontrato = epr.nrctremp));
  COMMIT;
END;