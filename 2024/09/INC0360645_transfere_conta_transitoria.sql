DECLARE
  
  vr_cdcooper    CONSTANT NUMBER := 1;
  vr_nrdconta    CONSTANT NUMBER := 12417157;
  vr_vlrlanc     CONSTANT NUMBER := 957.80;
  vr_dtmvtolt    DATE;
  vr_dsoperac    VARCHAR2(100) := 'Acerto Conta Transitoria - INC0360645';
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(2000);

BEGIN
  OPEN  btch0001.cr_crapdat(vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;

  PREJ0003.pc_gera_transf_cta_prj(pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_vllanmto => vr_vlrlanc
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_dsoperac => vr_dsoperac
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
                                  
  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    
    raise_application_error(-20000, 'Erro no script: '||vr_dscritic);
  END IF;
  
  COMMIT;
END;
