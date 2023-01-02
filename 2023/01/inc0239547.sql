
DECLARE

  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION; 
  vr_dslog        VARCHAR2(4000) := '';
  vr_idprglog NUMBER;
  vr_qtdregis INTEGER := 0;
   
  CURSOR cr_crapdir IS
  SELECT  dir.cdcooper, dir.nrdconta, dir.VLCAPMES##2
    FROM crapdir dir, crapass ass
   WHERE ass.cdcooper = dir.cdcooper
     AND ass.nrdconta = dir.nrdconta
     AND (ass.dtdemiss >= '01/03/2022' or ass.dtdemiss is null)
     AND dir.vlcapmes##3 = 0
     AND dir.vlcapmes##2 > 0
     AND dir.vlcapmes##4 > 0
     AND dir.dtmvtolt = to_date('30/12/2022','dd/mm/yyyy')
     AND dir.cdcooper = 1; 
     rw_crapdir cr_crapdir%ROWTYPE;

  CURSOR cr_craplct(pr_cdcooper IN craprda.cdcooper%TYPE
                   ,pr_nrdconta IN craprda.nrdconta%TYPE)IS
  SELECT nvl(SUM(decode(his.indebcre,'C',1,-1) * lct.vllanmto),0) vllanmto
    FROM craplct lct, craphis his
   WHERE lct.cdcooper = his.cdcooper
     AND lct.cdhistor = his.cdhistor
     AND lct.cdcooper = pr_cdcooper
     AND lct.nrdconta = pr_nrdconta
     AND lct.dtmvtolt between to_date('01/03/2022','dd/mm/yyyy') and to_date('31/03/2022','dd/mm/yyyy');
     rw_craplct cr_craplct%ROWTYPE;
    
BEGIN            
  CECRED.pc_log_programa(pr_dstiplog      => 'O'
                        ,pr_tpocorrencia  => 4 
                        ,pr_cdcriticidade => 0 
                        ,pr_tpexecucao    => 3 
                        ,pr_dsmensagem    => vr_dslog
                        ,pr_cdmensagem    => 111
                        ,pr_cdprograma    => 'INC0239547'
                        ,pr_cdcooper      => 3 
                        ,pr_idprglog      => vr_idprglog);
  FOR rw_crapdir IN cr_crapdir LOOP           
     
    OPEN cr_craplct(pr_cdcooper => rw_crapdir.cdcooper
                   ,pr_nrdconta => rw_crapdir.nrdconta);

    FETCH cr_craplct INTO rw_craplct;

    IF rw_craplct.vllanmto > 0 THEN
      CLOSE cr_craplct;                    
    ELSE
      CLOSE cr_craplct;   
      vr_dslog := 'nao encontrou registro na craplct Conta: ' || rw_crapdir.nrdconta;   
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dslog
                            ,pr_cdmensagem    => 222
                            ,pr_cdprograma    => 'INC0239547'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
     CONTINUE;
    END IF;                      
     vr_dslog := 'UPDATE cecred.crapdir SET VLCAPMES##3 = 0 WHERE CDCOOPER = '||rw_crapdir.cdcooper ||
                  ' AND NRDCONTA = '|| rw_crapdir.nrdconta ||
                  ' AND DTMVTOLT = TO_DATE(''30/12/2022'',''DD/MM/YYYY'');'; 
     CECRED.pc_log_programa(pr_dstiplog      => 'O'
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dslog
                            ,pr_cdmensagem    => 333
                            ,pr_cdprograma    => 'INC0239547'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);             
    BEGIN
      UPDATE cecred.crapdir 
         SET VLCAPMES##3 = VLCAPMES##2 +  rw_craplct.vllanmto
       WHERE cdcooper = rw_crapdir.cdcooper
         AND nrdconta = rw_crapdir.nrdconta
         AND dtmvtolt = to_date('30/12/2022','dd/mm/yyyy');
      EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := 'Erro ao atualizar aplicação(crapdir). Detalhes: '||SQLERRM;
      RAISE vr_exc_saida;
    END;    
    
    vr_qtdregis := vr_qtdregis + 1;
    IF MOD(vr_qtdregis, 10000) = 0 THEN
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_dsmensagem    => 'Commit - ' || vr_qtdregis
                            ,pr_cdprograma    => 'INC0239547'
                            ,pr_cdcooper      => 3
                            ,pr_idprglog      => vr_idprglog);
      COMMIT;
    END IF;
  END LOOP;      
  
  COMMIT;   
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      vr_dscritic := nvl(vr_dscritic,' ') || 
                    ' - Cooper '|| rw_crapdir.cdcooper || ' Conta ' || rw_crapdir.nrdconta;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 444
                            ,pr_cdprograma    => 'INC0239547'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK;                        
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' ||
                      nvl(vr_dscritic,' ') || ' - Cooper '|| rw_crapdir.cdcooper || ' Conta ' || rw_crapdir.nrdconta ||
                      SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 555
                            ,pr_cdprograma    => 'INC0239547'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK;
END;