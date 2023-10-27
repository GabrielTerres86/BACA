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
   where t.nrdconta = 16615000
     and t.cdcooper = 2
     and t.dtmvtolt = to_date('24/10/2023')
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
 
                               
     vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '16615000;2',
                             pr_flgdecre => 'N');                           
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 2,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 21,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 16615000,
                                                pr_nrdctabb    => 16615000,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 64000,
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
