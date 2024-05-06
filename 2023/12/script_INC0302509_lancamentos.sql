DECLARE
  vr_cdcooper    crapcop.cdcooper%TYPE := 1;   
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_exc_saida   EXCEPTION;
  vr_dtmvtolt    DATE;
  rw_crapdat     CECRED.BTCH0001.cr_crapdat%ROWTYPE;
    
BEGIN  
  
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;
  
  IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE cecred.btch0001.cr_crapdat;
    raise vr_exc_saida;
  ELSE
    CLOSE cecred.btch0001.cr_crapdat;
  END IF;
  vr_dtmvtolt := rw_crapdat.dtmvtolt;
  
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 100,
                                     pr_nrdolote    => 1473,
                                     pr_nrdocmto    => 180,
                                     pr_nrdconta    => 89208390,
                                     pr_cdhistor    => 2670,
                                     pr_vllanmto    => to_char('265,89'),
                                     pr_cdpesqbb    => 'Desconto de Título do Borderô ' || 1595880, 
                                     pr_cdoperad    => 1,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic,
                                     pr_incrineg    => vr_incrineg,
                                     pr_tab_retorno => vr_tab_retorno);
                                                                                                                                 
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF;
   

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
END;
