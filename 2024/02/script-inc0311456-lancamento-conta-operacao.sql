DECLARE
  vr_cdcooper    crapcop.cdcooper%TYPE := 16;
  vr_nrdconta    crapass.nrdconta%TYPE := 97792870; -- 2207060 --  97792870 dev
  vr_nrborder    crapbdt.nrborder%TYPE := 109412;
  vr_nrdocmto    craptdb.nrdocmto%TYPE := 0;
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
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 100,
                                     pr_nrdolote    => 87,
                                     pr_nrdocmto    => vr_nrdocmto,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_cdhistor    => 2805,
                                     pr_vllanmto    => to_char('317,15'),
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
                                        ,pr_cdbandoc => 0
                                        ,pr_nrdctabb => 2207060
                                        ,pr_nrcnvcob => 0
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_nrtitulo => 0
                                        ,pr_cdorigem => 5
                                        ,pr_cdhistor => 2811
                                        ,pr_vllanmto => to_char('317,15')
                                        ,pr_dscritic => vr_dscritic );
                                        
  IF vr_dscritic IS NOT NULL THEN
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
