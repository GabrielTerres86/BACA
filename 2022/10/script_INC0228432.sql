DECLARE
  vr_exc_saida    EXCEPTION;
  vr_cdcritic     crapcri.cdcritic%TYPE := 0;
  vr_dscritic     crapcri.dscritic%TYPE := NULL;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg      INTEGER;
  vr_nrdconta     crapttl.nrdconta%TYPE := 15653080;
  vr_cdcooper     crapttl.cdcooper%TYPE := 13;
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;


BEGIN
  
  APLI0002.pc_excluir_nova_aplicacao(pr_cdcooper => vr_cdcooper,
                                     pr_cdageope => 1,
                                     pr_nrcxaope => 100,
                                     pr_cdoperad => 1,
                                     pr_nmdatela => 'ATENDA',
                                     pr_idorigem => 5,
                                     pr_nrdconta => vr_nrdconta,
                                     pr_idseqttl => 1,
                                     pr_dtmvtolt => to_date('28/10/2022','dd/mm/yyyy'),
                                     pr_nraplica => 9,
                                     pr_flgerlog => 0,
                                     pr_cdcritic => vr_cdcritic,
                                     pr_dscritic => vr_dscritic);

  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao excluir registro de aplicacao. Erro: ' || vr_dscritic || vr_cdcritic;
    RAISE vr_exc_saida;
  END IF;  
                                       
  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => vr_cdcooper
                                    ,pr_dtmvtolt => to_date('28/10/2022','dd/mm/yyyy')
                                    ,pr_cdagenci => 1
                                    ,pr_cdbccxlt => 100
                                    ,pr_nrdolote => 8599
                                    ,pr_nrdconta => vr_nrdconta
                                    ,pr_nrdctabb => vr_nrdconta
                                    ,pr_nrdocmto => 999999
                                    ,pr_nrseqdig => 999999
                                    ,pr_dtrefere => to_date('28/10/2022','dd/mm/yyyy')
                                    ,pr_vllanmto => 50000.01
                                    ,pr_cdhistor => 3812 
                                    ,pr_inprolot => 1
                                    ,pr_tplotmov => 1
                                    ,pr_tab_retorno => vr_tab_retorno
                                    ,pr_incrineg => vr_incrineg
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
 
  IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' || vr_dscritic || vr_cdcritic;
    RAISE vr_exc_saida;
  END IF;  
  
  BEGIN
    INSERT INTO cecred.craplci 
      (CDAGENCI, 
       CDBCCXLT, 
       DTMVTOLT, 
       NRDOLOTE, 
       NRDCONTA, 
       CDHISTOR, 
       NRDOCMTO, 
       NRSEQDIG, 
       VLLANMTO, 
       CDCOOPER, 
       NRAPLICA)
       VALUES 
       (7, 
        0, 
        to_date('28-10-2022', 'dd-mm-yyyy'), 
        9900010105, 
        15653080, 
        3843, 
        '999999', 
        0, 
        50000.01, 
        13, 
        4); 
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir na tabela craplci: '||SQLERRM;
      RAISE vr_exc_saida;
  END;
  COMMIT;   
 EXCEPTION 
    WHEN vr_exc_saida then  
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 888
                           ,pr_cdprograma    => 'INC0228432'
                           ,pr_cdcooper      => 13 
                           ,pr_idprglog      => vr_idprglog);   
      ROLLBACK;    
    WHEN OTHERS then
      vr_dscritic :=  sqlerrm;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 999
                           ,pr_cdprograma    => 'INC0228432'
                           ,pr_cdcooper      => 13 
                           ,pr_idprglog      => vr_idprglog);
      ROLLBACK;               
END;
