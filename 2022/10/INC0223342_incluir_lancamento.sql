DECLARE
  vr_exc_saida    EXCEPTION;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     INTEGER;
  vr_cdcritic     crapcri.cdcritic%TYPE := 0;
  vr_dscritic     crapcri.dscritic%TYPE := NULL;  
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
BEGIN
  BEGIN
    INSERT INTO CECRED.craplac 
      (CDCOOPER, 
       NRDCONTA, 
       NRAPLICA, 
       CDAGENCI, 
       CDBCCXLT, 
       DTMVTOLT, 
       NRDOLOTE, 
       NRDOCMTO, 
       NRSEQDIG, 
       VLLANMTO, 
       CDHISTOR, 
       VLRENDIM,  
       VLBASREN, 
       NRSEQRGT,  
       CDCANAL)
    VALUES 
      (1, 
       85049832, 
       1, 
       1, 
       100, 
       to_date(sysdate, 'dd-mm-yyyy'), 
       850999, 
       1, 
       1, 
       105.15, 
       3528, 
       0.00,  
       0.00, 
       0,  
       0);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir na tabela craplac: ' || SQLERRM;
      RAISE vr_exc_saida;
  END;

  LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => 1
                                    ,pr_dtmvtolt => to_date(sysdate,'dd/mm/yyyy')
                                    ,pr_cdagenci => 1
                                    ,pr_cdbccxlt => 100
                                    ,pr_nrdolote => 8599
                                    ,pr_nrdconta => 85049832
                                    ,pr_nrdctabb => 85049832
                                    ,pr_nrdocmto => 999999
                                    ,pr_nrseqdig => 999999
                                    ,pr_dtrefere => to_date(sysdate,'dd/mm/yyyy')
                                    ,pr_vllanmto => 105.15
                                    ,pr_cdhistor => 3529 
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