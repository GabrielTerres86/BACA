DECLARE
   vr_excsaida     EXCEPTION;
   vr_dscritic     VARCHAR2(5000) := ' ';
   vr_nrseqdig     NUMBER := 0;
   vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
   rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

   CURSOR cr_craprda IS
    select 16 cdcooper, 99453061 nrdconta, 1 nraplica, 0.79 vllanmto from dual;
   rw_craprda cr_craprda%ROWTYPE;     
      

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
      
  FOR rw_craprda in cr_craprda LOOP 
    vr_nrseqdig := vr_nrseqdig + 1;
   
    BEGIN    
      INSERT INTO cecred.craplap(cdcooper
                       ,dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrdconta
                       ,nraplica
                       ,nrdocmto
                       ,txaplica
                       ,txaplmes
                       ,cdhistor
                       ,nrseqdig
                       ,vllanmto
                       ,dtrefere
                       ,vlrendmm)
          VALUES(rw_craprda.cdcooper
                ,rw_crapdat.dtmvtolt
                ,1
                ,100
                ,456999 
                ,rw_craprda.nrdconta
                ,rw_craprda.nraplica
                ,555001
                ,0
                ,0
                ,531
                ,vr_nrseqdig
                ,rw_craprda.vllanmto
                ,rw_crapdat.dtmvtolt
                ,0) ;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir craplap. Detalhes: '||sqlerrm;
          RAISE vr_excsaida;
    END;
    
      BEGIN 
        UPDATE cecred.craprda a
           SET a.vlsltxmx = 0,
               a.vlsltxmm = 0,
               a.vlsdrdca = 0
         WHERE a.cdcooper = rw_craprda.cdcooper
           AND a.nrdconta = rw_craprda.nrdconta
           AND a.nraplica = rw_craprda.nraplica;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar craprda. Detalhes: '||sqlerrm;
          RAISE vr_excsaida;
      END;     
                        
  END LOOP;

  COMMIT;

  EXCEPTION 
    WHEN vr_excsaida then  
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 888
                           ,pr_cdprograma    => 'INC0263156'
                           ,pr_cdcooper      => 3 
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
                           ,pr_cdprograma    => 'INC0263156'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
      ROLLBACK; 
END;
