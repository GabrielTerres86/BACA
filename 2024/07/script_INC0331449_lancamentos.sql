DECLARE
  vr_cdcooper    crapcop.cdcooper%TYPE := 7;
  vr_nrdconta    crapass.nrdconta%TYPE := 436380;
  vr_nrborder    crapbdt.nrborder%TYPE := 71033;
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_exc_saida   EXCEPTION;
  rw_crapdat     datasCooperativa;
    
BEGIN
  rw_crapdat := datasCooperativa(pr_cdcooper => vr_cdcooper);
  
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_cdhistor    => 2670,
                                     pr_vllanmto    => to_char('10772,69'),
                                     pr_cdpesqbb    => 'Desconto de Título do Borderô ' || vr_nrborder, 
                                     pr_cdoperad    => 1,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic,
                                     pr_incrineg    => vr_incrineg,
                                     pr_tab_retorno => vr_tab_retorno);
                                                                                                                                 
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF;
  
  
  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrborder => vr_nrborder
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdorigem => 5
                                        ,pr_cdhistor => 2671
                                        ,pr_vllanmto => to_char('10905,00')
                                        ,pr_dscritic => vr_dscritic );
                                        
  IF vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF; 
  
  
  UPDATE cecred.crapbdt a
     SET a.insitbdt = 4
   WHERE a.cdcooper = vr_cdcooper
     AND a.nrdconta = vr_nrdconta
     AND a.nrborder = vr_nrborder;

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
END;
