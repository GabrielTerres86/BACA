declare
  vr_nrdocmto    CECRED.craplci.nrdocmto%TYPE;
  vr_cdcritic    CECRED.crapcri.cdcritic%TYPE := 0;
  vr_dscritic    CECRED.crapcri.dscritic%TYPE := NULL;
  vr_tab_retorno CECRED.LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_dtmvtolt    CECRED.crapdat.dtmvtolt%type;
  i              integer;
  vr_mensagem    varchar2(4000);
  vr_tentativas  integer := 50;
Begin

  delete from CECRED.tbcc_lancamentos_pendentes t
   where t.nrdconta = 16288548
     and t.cdcooper = 2
     and t.dtmvtolt = '13/10/2023'
     and t.nrdcmto = 2003;

  select t.dtmvtolt
    into vr_dtmvtolt
    from CECRED.crapdat t
   where t.cdcooper = 2;
  i := 0;
  loop
    i := i + 1;
    if i = vr_tentativas then
      raise_application_error(-20001, vr_mensagem);
    end if;
    vr_nrdocmto := fn_sequence('CRAPLCM',
                               'NRDOCMTO',
                               '' || to_char(2) || ';' ||
                               to_char(vr_dtmvtolt, 'DD/MM/RRRR') || ';' || 15 || ';' || 0 || ';' || 8503);
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 2,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 15,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 16288548,
                                                pr_nrdctabb    => 16288548,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 158802.87,
                                                pr_cdhistor    => 3813,
                                                pr_inprolot    => 1,
                                                pr_tplotmov    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                       vr_dscritic;
        raise_application_error('-20001', vr_dscritic);
      end if;
      exit;
    EXCEPTION
      WHEN OTHERS THEN
        Begin
          vr_mensagem := sqlerrm;
        End;
    end;
  end loop;

  delete from CECRED.tbcc_lancamentos_pendentes t
   where t.nrdconta = 16307852
     and t.cdcooper = 2
     and t.dtmvtolt = '16/10/2023'
     and t.nrdcmto = 2003;

  select t.dtmvtolt
    into vr_dtmvtolt
    from CECRED.crapdat t
   where t.cdcooper = 2;

  i := 0;
  loop
    i := i + 1;
    if i = 10 then
      raise_application_error(-20001, vr_mensagem);
    end if;
    vr_nrdocmto := fn_sequence('CRAPLCM',
                               'NRDOCMTO',
                               '' || to_char(2) || ';' ||
                               to_char(vr_dtmvtolt, 'DD/MM/RRRR') || ';' || 15 || ';' || 0 || ';' || 8503);
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 2,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 15,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 16307852,
                                                pr_nrdctabb    => 16307852,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 1500.00,
                                                pr_cdhistor    => 3813,
                                                pr_inprolot    => 1,
                                                pr_tplotmov    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                       vr_dscritic;
        raise_application_error('-20001', vr_dscritic);
      end if;
      exit;
    EXCEPTION
      WHEN OTHERS THEN
        Begin
          vr_mensagem := sqlerrm;
        End;
    end;
  end loop;

  delete from CECRED.tbcc_lancamentos_pendentes t
   where t.nrdconta = 528382
     and t.cdcooper = 16
     and t.dtmvtolt = '16/10/2023'
     and t.nrdcmto = 2003;

  select t.dtmvtolt
    into vr_dtmvtolt
    from CECRED.crapdat t
   where t.cdcooper = 16;

  vr_nrdocmto := fn_sequence('CRAPLCM',
                             'NRDOCMTO',
                             '' || to_char(16) || ';' ||
                             to_char(vr_dtmvtolt, 'DD/MM/RRRR') || ';' || 11 || ';' || 0 || ';' || 8503);

  i := 0;
  loop
    i := i + 1;
    if i = 10 then
      raise_application_error(-20001, vr_mensagem);
    end if;
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 16,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 11,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 528382,
                                                pr_nrdctabb    => 528382,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 30000.00,
                                                pr_cdhistor    => 3813,
                                                pr_inprolot    => 1,
                                                pr_tplotmov    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                       vr_dscritic;
        raise_application_error('-20001', vr_dscritic);
      end if;
      exit;
    EXCEPTION
      WHEN OTHERS THEN
        Begin
          vr_mensagem := sqlerrm;
        End;
    end;
  end loop;
  commit;
END;
