DECLARE
  vr_cdcooper    crapcop.cdcooper%TYPE := 1;
  vr_nrdconta    crapass.nrdconta%TYPE := 89505832;
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
                                     pr_nrdolote    => 8450,
                                     pr_nrseqdig    => 1,
                                     pr_nrdocmto    => 99991,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_cdhistor    => 1667,
                                     pr_vllanmto    => 56.92,
                                     pr_cdpesqbb    => 'Estorno historico 37 ref. 07/2023', 
                                     pr_cdoperad    => 1,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic,
                                     pr_incrineg    => vr_incrineg,
                                     pr_tab_retorno => vr_tab_retorno);
                                                                                                                                 
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF; 
  
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 100,
                                     pr_nrdolote    => 8450,
                                     pr_nrseqdig    => 2,
                                     pr_nrdocmto    => 99992,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_cdhistor    => 1667,
                                     pr_vllanmto    => 65.45,
                                     pr_cdpesqbb    => 'Estorno historico 37 ref. 08/2023', 
                                     pr_cdoperad    => 1,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic,
                                     pr_incrineg    => vr_incrineg,
                                     pr_tab_retorno => vr_tab_retorno);
                                                                                                                                 
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF;
  
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => vr_cdcooper,
                                     pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                     pr_cdagenci    => 1,
                                     pr_cdbccxlt    => 100,
                                     pr_nrdolote    => 8450,
                                     pr_nrseqdig    => 3,
                                     pr_nrdocmto    => 99993,
                                     pr_nrdconta    => vr_nrdconta,
                                     pr_cdhistor    => 1667,
                                     pr_vllanmto    => 28.46,
                                     pr_cdpesqbb    => 'Estorno historico 37 ref. 09/2023', 
                                     pr_cdoperad    => 1,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic,
                                     pr_incrineg    => vr_incrineg,
                                     pr_tab_retorno => vr_tab_retorno);
                                                                                                                                 
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF;
  
  begin  
    update gestaoderisco.tbcc_historico_juros_lanc l
       set l.vlhistor = 0
     where l.idhistorico_juros_adp = (select idhistorico_juros_adp 
                                      from gestaoderisco.tbcc_historico_juros_adp his 
                                     where his.cdcooper = vr_cdcooper 
                                       and his.nrdconta = vr_nrdconta
                                       and his.dtmvtolt = rw_crapdat.dtmvtoan);
                                       
    if sql%rowcount = 0 then
      raise vr_exc_saida;
    end if;
      
    update gestaoderisco.tbcc_historico_juros_adp his
            set his.vlcorte = 0
               ,his.qtdiaatr = 0
          where his.cdcooper = vr_cdcooper
            and his.nrdconta = vr_nrdconta
            and his.dtmvtolt = rw_crapdat.dtmvtoan;
            
    if sql%rowcount = 0 then
      raise vr_exc_saida;
    end if;
    
    update crapsld sld 
       set sld.vliofmes = 0
     where sld.cdcooper = vr_cdcooper
       and sld.nrdconta = vr_nrdconta;
       
    if sql%rowcount = 0 then
      raise vr_exc_saida;
    end if;  
      
  exception
    when others then
      raise vr_exc_saida;
  end;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    ROLLBACK;
END;
