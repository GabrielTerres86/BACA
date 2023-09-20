BEGIN
  INSERT INTO credito.tbcred_pronampe_repasse
    (SELECT a.cdcooper
           ,a.nrdconta
           ,a.nrcontrato
           ,b.dtmvtolt
           ,c.vlsaldhonrrec
           ,a.idcontrato
           ,(SELECT MAX(d.nrremessa)
               FROM credito.tbcred_pronampe_retremessa d
              WHERE d.tpregistro = 97
                AND d.cdmovimentacaofi = 5
                AND d.idcontrato = a.idcontrato) nrremessa
       FROM credito.tbcred_pronampe_contrato  a
           ,cecred.crapdat                    b
           ,credito.tbcred_pronampe_infdiario c
      WHERE a.cdcooper = b.cdcooper
        AND a.idcontrato = c.idcontrato
        AND a.idcontrato = 3077707
        AND c.tpregistro = 98
        AND c.idregistro = (SELECT MAX(d.idregistro)
                              FROM credito.tbcred_pronampe_infdiario d
                             WHERE d.idcontrato = c.idcontrato
                               AND d.tpregistro = c.tpregistro));

  UPDATE credito.tbcred_pronampe_contrato a
     SET a.vltotalrepasse =
         (SELECT SUM(b.vlrepasse)
            FROM credito.tbcred_pronampe_repasse b
           WHERE b.idcontrato = a.idcontrato)
        ,a.vlsaldohonra   = 0
   WHERE a.idcontrato = 3077707;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
