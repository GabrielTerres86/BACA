DECLARE
  vr_cdcooper    crapcop.cdcooper%TYPE := 6;
  vr_nrdconta    crapass.nrdconta%TYPE := 116874;
  vr_cdhistor    craphis.cdhistor%TYPE := 37;
  vr_lancamento  craplcm.vllanmto%TYPE := '1921,63'; 
  vr_nrdolote    craplcm.nrdolote%TYPE := 8450;
  vr_nrseqdig    craplcm.nrseqdig%TYPE := 0;
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_exc_saida   EXCEPTION;
  rw_crapdat     datasCooperativa;
    
BEGIN
  rw_crapdat := datasCooperativa(pr_cdcooper => vr_cdcooper);
  
  vr_nrseqdig := CRAPLOT_8450_SEQ.NEXTVAL;

  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 100,
									 pr_nrdolote    => vr_nrdolote,									 
									 pr_nrdocmto => 99999937 || substr(to_char(vr_nrseqdig),0,17),
									 pr_nrseqdig => vr_nrseqdig,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_cdhistor    => vr_cdhistor,
                                     pr_vllanmto    => to_char(vr_lancamento),
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
