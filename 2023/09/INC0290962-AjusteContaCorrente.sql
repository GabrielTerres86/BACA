declare

  vr_nrdocmto    craplci.nrdocmto%TYPE;
  vr_cdcritic    crapcri.cdcritic%TYPE := 0;
  vr_dscritic    crapcri.dscritic%TYPE := NULL;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
Begin

  vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCI_LCI',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '11092023;2',
                             pr_flgdecre => 'N');

  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 2,
                                     pr_dtmvtolt => '11/09/2023',
                                     pr_cdagenci => 1,
                                     pr_cdbccxlt => 100,
                                     pr_nrdolote => 8599,
                                     pr_nrdconta => 16278860,
                                     pr_nrdctabb => 16278860,
                                     pr_nrdocmto => vr_nrdocmto,
                                     pr_nrseqdig => vr_nrdocmto,
                                     pr_dtrefere => to_date('11/09/2023'),
                                     pr_vllanmto => 2000,
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

  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 16,
                                     pr_dtmvtolt => '11/09/2023',
                                     pr_cdagenci => 1,
                                     pr_cdbccxlt => 100,
                                     pr_nrdolote => 8599,
                                     pr_nrdconta => 620882,
                                     pr_nrdctabb => 620882,
                                     pr_nrdocmto => vr_nrdocmto,
                                     pr_nrseqdig => vr_nrdocmto,
                                     pr_dtrefere => to_date('11/09/2023'),
                                     pr_vllanmto => 74190.05,
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
