DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';
   vr_nrseqdig   NUMBER := 0;
   vr_tab_retorno          LANC0001.typ_reg_retorno;
   vr_incrineg             INTEGER;
   vr_dslog VARCHAR2(4000) := '';
   vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  
   rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

   CURSOR cr_craprac IS
     select 1 cdcooper, 12673897 nrdconta, 3  nraplica, 38.00 vllanmto from dual union all
     select 1 cdcooper,  9120009 nrdconta, 60 nraplica, 24.45 vllanmto from dual union all
     select 1 cdcooper,  7571399 nrdconta, 24 nraplica,  5.16 from dual;
    rw_craprac cr_craprac%ROWTYPE;           

BEGIN

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND THEN        
    CLOSE btch0001.cr_crapdat;       
    RAISE vr_excsaida;
  ELSE      
    CLOSE btch0001.cr_crapdat;
  END IF;
      
  FOR rw_craprac in cr_craprac LOOP 
    
  BEGIN
    UPDATE cecred.craprac
       SET vlbasapl = 0,
           vlslfmes = 0,
           vlsldant = 0,
           vlsldatl = 0,
           idsaqtot = 1 
     WHERE cdcooper = rw_craprac.cdcooper
       AND nrdconta = rw_craprac.nrdconta
       AND nraplica = rw_craprac.nraplica;
    EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualiza craprac. Detalhes: '||sqlerrm;
            RAISE vr_excsaida;
  END;

         cecred.APLI0010.pc_processa_lote_aniv(pr_cdcooper => rw_craprac.cdcooper
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdagenci => 1
                                      ,pr_cdbccxlt => 100
                                      ,pr_nrdolote => 558506
                                      ,pr_cdoperad => '1'
                                      ,pr_vllanmto => rw_craprac.vllanmto
                                      ,pr_vllanneg => 0
                                      ,pr_nrseqdig => vr_nrseqdig
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro criando lote - ' || nvl(vr_dscritic,' ');
          RAISE vr_excsaida;
        END IF;
            cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => rw_craprac.cdcooper
                                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                     ,pr_cdagenci => 1 
                                                     ,pr_cdbccxlt => 100 
                                                     ,pr_nrdolote => 8599
                                                     ,pr_nrdconta => rw_craprac.nrdconta
                                                     ,pr_nrdctabb => rw_craprac.nrdconta
                                                     ,pr_nrdocmto => rw_craprac.nraplica
                                                     ,pr_nrseqdig => vr_nrseqdig
                                                     ,pr_dtrefere => rw_crapdat.dtmvtolt
                                                     ,pr_vllanmto => rw_craprac.vllanmto
                                                     ,pr_cdhistor => 362
                                                     ,pr_nraplica => rw_craprac.nraplica       
                                                     ,pr_tab_retorno => vr_tab_retorno
                                                     ,pr_incrineg => vr_incrineg
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_excsaida;
          END IF;
      

  END LOOP;

  COMMIT;

  EXCEPTION 
     WHEN vr_excsaida then  
     CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 888
                           ,pr_cdprograma    => 'INC0192972_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);   
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
     CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog || '. ' || vr_dscritic
                           ,pr_cdmensagem    => 999
                           ,pr_cdprograma    => 'INC0192972_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 

END;
