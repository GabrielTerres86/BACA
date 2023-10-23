DECLARE
  vr_cdhistor crappco.dsconteu%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
BEGIN
  credito.obterParamCadpar(pr_cdcooper => 3,
                           pr_nmpartar => 'CDHSTRECPVLPEAC',
                           pr_vlparamt => vr_cdhistor,
                           pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  INSERT INTO credito.tbcred_peac_recuperacao
  (idpeac_contrato
  ,dtrecuperacao
  ,vlrecuperado)
  (SELECT ctr.idpeac_contrato
         ,lem.dtmvtolt
         ,SUM(lem.vllanmto) vllanmto
     FROM credito.tbcred_peac_contrato ctr
         ,cecred.craplem               lem
    WHERE ctr.cdcooper = lem.cdcooper
      AND ctr.nrdconta = lem.nrdconta
      AND ctr.nrcontrato = lem.nrctremp
      AND instr(',' || vr_cdhistor || ',', ',' || lem.cdhistor || ',') > 0
      AND ctr.cdsituacaohonra = 2
      AND nvl(ctr.vlsaldorecuperar, 0) > 0
      AND lem.dtmvtolt > trunc(ctr.dtsolicitacaohonra)
      AND NOT EXISTS 
          (SELECT 1
             FROM credito.tbcred_peac_recuperacao rec
            WHERE rec.idpeac_contrato = ctr.idpeac_contrato
              AND rec.dtrecuperacao = lem.dtmvtolt)
    GROUP BY ctr.idpeac_contrato
            ,lem.dtmvtolt);

  UPDATE credito.tbcred_peac_recuperacao a
     SET a.idpeac_operacao =
         (SELECT MIN(b.idpeac_operacao)
            FROM credito.tbcred_peac_operacao b
           WHERE b.idpeac_contrato = a.idpeac_contrato
             AND b.cdstatus = 'APROVADA'
             AND (trunc(b.dhoperacao) = sistema.validarDiaUtil(pr_cdcooper => 3,
                                                               pr_dtmvtolt => a.dtrecuperacao + 1,
                                                               pr_tipo     => 'P') 
              OR (trunc(b.dhoperacao) = to_date('06/07/2023', 'DD/MM/RRRR') AND b.vlrecuperacao = a.vlrecuperado) 
              OR b.idpeac_operacao = 5065));

  UPDATE credito.tbcred_peac_contrato c
     SET c.vlsaldorecuperar = 0
   WHERE c.idpeac_contrato = 959
     AND c.vlsaldorecuperar > 0;

  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
