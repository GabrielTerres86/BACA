BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.cdsituacaohonra    = 2
        ,a.vlsolicitacaohonra =
         (SELECT CASE
                   WHEN epr.idfiniof = 1 THEN
                    (epr.vlemprst - epr.vltarifa) * 0.8
                   ELSE
                    epr.vlemprst * 0.8
                 END vlhonra
            FROM crapepr epr
           WHERE epr.cdcooper = a.cdcooper
             AND epr.nrdconta = a.nrdconta
             AND epr.nrctremp = a.nrcontrato)
        ,a.dtsolicitacaohonra = SYSDATE
        ,a.vlsaldorecuperar  =
         (SELECT CASE
                   WHEN epr.idfiniof = 1 THEN
                    (epr.vlemprst - epr.vltarifa) * 0.8
                   ELSE
                    epr.vlemprst * 0.8
                 END vlhonra
            FROM crapepr epr
           WHERE epr.cdcooper = a.cdcooper
             AND epr.nrdconta = a.nrdconta
             AND epr.nrctremp = a.nrcontrato)
   WHERE a.idpeac_contrato = 2032;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
