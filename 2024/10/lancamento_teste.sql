DECLARE

 n_cdcooper number := 5;
 n_nrdconta number := 99968754;
 rw_crapdat SISTEMA.DatasCooperativa;
 vr_nrseqdig  number;
 vr_nrdocmto  number;
 vr_incrineg integer;
 vr_tab_retorno CONTACORRENTE.tipoRegRetorno.typ_reg_retorno;
 vr_cdcritic NUMBER(5);
 vr_dscritic VARCHAR2(4000);
 vr_busca    VARCHAR2(100);
 dt_cooperativa date := to_date('20/10/2024','dd/mm/yyyy');
 
 cursor c_dados(p_cdcooper number, p_nrdconta number) IS
   select cdagenci 
     from cecred.crapass
  where cdcooper = p_cdcooper
    and nrdconta = p_nrdconta;
 dconta c_dados%rowtype;
 





BEGIN

 open c_dados(n_cdcooper, n_nrdconta);
 fetch c_dados into dconta;
 close c_dados;
      
 rw_crapdat  := SISTEMA.DatasCooperativa(n_cdcooper);
 
 vr_busca := TRIM(to_char(n_cdcooper)) || ';' ||
             TRIM(to_char(dt_cooperativa, 'DD/MM/RRRR')) || ';' ||
             TRIM(to_char(dconta.cdagenci)) || ';' || '100;' ||600038;
 
 vr_nrdocmto := SISTEMA.obterSequence('CRAPLCT', 'NRDOCMTO', vr_busca);
 
 vr_nrseqdig := SISTEMA.obterSequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,'' || n_cdcooper || ';' ||
                                       to_char(dt_cooperativa, 'DD/MM/RRRR') || ';' ||
                                       dconta.cdagenci || ';100;' ||
                                       600038);

  CONTACORRENTE.registrarLancamentoConta(pr_cdcooper => n_cdcooper
                                        ,pr_dtmvtolt => dt_cooperativa
                                        ,pr_dtrefere => dt_cooperativa
                                        ,pr_cdagenci => dconta.cdagenci
                                        ,pr_cdbccxlt => 100
                                        ,pr_nrdolote => 600038
                                        ,pr_nrdconta => n_nrdconta
                                        ,pr_nrdctabb => n_nrdconta
                                        ,pr_nrdctitg => TO_CHAR(SISTEMA.formatarMascara(n_nrdconta,'99999999'))
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_cdhistor => 4345
                                        ,pr_vllanmto => 100
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS'))
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg    => vr_incrineg
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_dscritic    => vr_dscritic);

   if nvl(vr_cdcritic, 0) > 0 OR
      vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('Erro ao efetuar lançamento');
   end if;

  commit;

END;
