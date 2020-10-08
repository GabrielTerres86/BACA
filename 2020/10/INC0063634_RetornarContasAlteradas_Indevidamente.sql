DECLARE

  CURSOR cr_contas(pr_idprglog IN NUMBER) IS
   SELECT substr(t.dsmensagem,0,INSTR(t.dsmensagem,'#')-1) nrdconta
     FROM tbgen_prglog_ocorrencia t 
    WHERE t.idprglog = pr_idprglog;   -- 20598126(7) -- 20588669(6)
  
  vr_dscritic   VARCHAR2(2000);
  
BEGIN
  
  -- Voltar as contas para tipo 7
  FOR reg IN cr_contas(20598126) LOOP
    
    UPDATE crapass ass
       SET ass.cdtipcta = 7 -- Conta anterior
     WHERE ass.cdcooper = 1 -- Viacredi
       AND ass.nrdconta = reg.nrdconta -- Conta registrada no Log
       AND ass.cdtipcta = 19; -- Conta que foi alterada
    
    CADA0006.pc_grava_dados_hist(pr_nmtabela => 'CRAPASS'
                                ,pr_nmdcampo => 'CDTIPCTA'
                                ,pr_cdcooper => 1
                                ,pr_nrdconta => reg.nrdconta
                                ,pr_idseqttl => 1 -- Colocar como titular
                                ,pr_tpoperac => 2 -- Alteração
                                ,pr_dsvalant => 19 -- Tipo de conta atual
                                ,pr_dsvalnov => 7 -- Novo tipo de conta
                                ,pr_cdoperad => 1 -- Super Usuário
                                ,pr_dscritic => vr_dscritic);
    
  END LOOP;

  -- Voltar as contas para tipo 6
  FOR reg IN cr_contas(20588669) LOOP
    
    UPDATE crapass ass
       SET ass.cdtipcta = 6 -- Conta anterior
     WHERE ass.cdcooper = 1 -- Viacredi
       AND ass.nrdconta = reg.nrdconta -- Conta registrada no Log
       AND ass.cdtipcta = 19; -- Conta que foi alterada
    
    CADA0006.pc_grava_dados_hist(pr_nmtabela => 'CRAPASS'
                                ,pr_nmdcampo => 'CDTIPCTA'
                                ,pr_cdcooper => 1
                                ,pr_nrdconta => reg.nrdconta
                                ,pr_idseqttl => 1 -- Colocar como titular
                                ,pr_tpoperac => 2 -- Alteração
                                ,pr_dsvalant => 19 -- Tipo de conta atual
                                ,pr_dsvalnov => 6 -- Novo tipo de conta
                                ,pr_cdoperad => 1 -- Super Usuário
                                ,pr_dscritic => vr_dscritic);
    
  END LOOP;
 
  COMMIT;

END;
