DECLARE 
 
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nrdconta      crapepr.nrdconta%TYPE;
  vr_nrctremp      crapepr.nrctremp%TYPE;
  vr_vllanmto      craplem.vllanmto%TYPE;
  
  vr_contrato      GENE0002.typ_split;
  vr_dadosctr      GENE0002.typ_split;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => 9);
  FETCH btch0001.cr_crapdat  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  DELETE FROM craplem WHERE cdcooper = 9 AND nrdconta = 511307 AND progress_recid = 261536584;
  
  empr0001.pc_cria_lancamento_lem(pr_cdcooper => 9
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => 1
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 600029
                                 ,pr_nrdconta => 511307
                                 ,pr_cdhistor => 2392 
                                 ,pr_nrctremp => 10007981
                                 ,pr_vllanmto => 395672.77
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 0
                                 ,pr_flgincre => TRUE 
                                 ,pr_flgcredi => FALSE  
                                 ,pr_nrseqava => 0
                                 ,pr_cdorigem => 7 -- batch
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
           
  --Se ocorreu erro
  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    --Levantar Excecao
    RAISE vr_exc_erro;
  END IF;
      
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20111, SQLERRM);
END;
