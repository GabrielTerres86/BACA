declare

  vr_nrdocmto    CECRED.craplci.nrdocmto%TYPE;
  vr_cdcritic    CECRED.crapcri.cdcritic%TYPE := 0;
  vr_dscritic    CECRED.crapcri.dscritic%TYPE := NULL;
  vr_tab_retorno CECRED.LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_dtmvtolt    CECRED.crapdat.dtmvtolt%type;
Begin

  delete from CECRED.tbcc_lancamentos_pendentes t
   where t.nrdconta = 14568772
     and t.cdcooper = 2
     and t.dtmvtolt = '11/10/2023'
     and t.nrdcmto = 2003
     and t.cdproduto = 3;

  select t.dtmvtolt into vr_dtmvtolt from CECRED.crapdat t where t.cdcooper = 2;
  
  
  vr_nrdocmto := CECRED.fn_sequence(pr_nmtabela => 'CRAPLCI_LCI',
                                    pr_nmdcampo => 'NRDOCMTO',
                                    pr_dsdchave => '14568772;2',
                                    pr_flgdecre => 'N');

  CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 2,
                                            pr_dtmvtolt => vr_dtmvtolt,
                                            pr_cdagenci => 26,
                                            pr_cdbccxlt => 0,
                                            pr_nrdolote => 8503,
                                            pr_nrdconta => 14568772,
                                            pr_nrdctabb => 14568772,
                                            pr_nrdocmto => vr_nrdocmto,
                                            pr_nrseqdig => vr_nrdocmto,
                                            pr_dtrefere => vr_dtmvtolt,
                                            pr_vllanmto => 100000,
                                            pr_cdhistor => 3813,
                                            pr_inprolot => 1,
                                            pr_tplotmov => 1,
                                            pr_tab_retorno => vr_tab_retorno,
                                            pr_incrineg    => vr_incrineg,
                                            pr_cdcritic    => vr_cdcritic,
                                            pr_dscritic    => vr_dscritic);

  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                   vr_dscritic;
    raise_application_error('-20001', vr_dscritic);
  end if;
  
    delete from CECRED.tbcc_lancamentos_pendentes t
   where t.nrdconta = 528382
     and t.cdcooper = 16
     and t.dtmvtolt = '11/10/2023'
     and t.nrdcmto = 2003
     and t.cdproduto = 3;
  
  
  vr_nrdocmto := CECRED.fn_sequence(pr_nmtabela => 'CRAPLCI_LCI',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '528382;16',
                             pr_flgdecre => 'N');

  CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 16,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_cdagenci => 11,
                                     pr_cdbccxlt => 0,
                                     pr_nrdolote => 8503,
                                     pr_nrdconta => 528382,
                                     pr_nrdctabb => 528382,
                                     pr_nrdocmto => vr_nrdocmto,
                                     pr_nrseqdig => vr_nrdocmto,
                                     pr_dtrefere => vr_dtmvtolt,
                                     pr_vllanmto => 64000,
                                     pr_cdhistor => 3813,
                                     pr_inprolot => 1,
                                     pr_tplotmov => 1,
                                     pr_tab_retorno => vr_tab_retorno,
                                     pr_incrineg    => vr_incrineg,
                                     pr_cdcritic    => vr_cdcritic,
                                     pr_dscritic    => vr_dscritic);
                                     
   IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                   vr_dscritic;
    raise_application_error('-20001', vr_dscritic);
  end if;                                  
                                     
  commit;
  
EXCEPTION  
   
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado ao rodar script : ' || SQLERRM;
     raise_application_error('-20001', vr_dscritic);    
    ROLLBACK;  
END;