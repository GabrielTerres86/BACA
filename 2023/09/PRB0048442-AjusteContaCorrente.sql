declare

  vr_nrdocmto    craplci.nrdocmto%TYPE;
  vr_cdcritic    crapcri.cdcritic%TYPE := 0;
  vr_dscritic    crapcri.dscritic%TYPE := NULL;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_dtmvtolt    crapdat.dtmvtolt%type;
Begin
  
  delete from tbcc_lancamentos_pendentes t where t.idseq_lancamento in (307747589,313179302);

  select t.dtmvtolt into vr_dtmvtolt from crapdat t where t.cdcooper = 16;
  
  
  vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCI_LCI',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '1010107;16',
                             pr_flgdecre => 'N');

  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 16,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_cdagenci => 4,
                                     pr_cdbccxlt => 0,
                                     pr_nrdolote => 8503,
                                     pr_nrdconta => 1010107,
                                     pr_nrdctabb => 1010107,
                                     pr_nrdocmto => vr_nrdocmto,
                                     pr_nrseqdig => vr_nrdocmto,
                                     pr_dtrefere => vr_dtmvtolt,
                                     pr_vllanmto => 15000,
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
END;
