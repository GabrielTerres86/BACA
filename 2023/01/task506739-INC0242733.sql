
DECLARE 
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION; 
  vr_dslog VARCHAR2(4000) := '';
  vr_idprglog NUMBER;
  
  CURSOR cr_crapcop IS
   SELECT cdcooper
     FROM crapcop 
   WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
    
  CURSOR cr_craprda(pr_cdcooper IN NUMBER) IS
    SELECT ass.cdcooper, 
           ass.nrdconta, 
           ass.dtdemiss, 
           rda.nraplica,
           rda.insaqtot,
           rda.vlsdrdca,
           rda.vlsltxmx,
           rda.vlsltxmm
      FROM crapass ass,
           craprda rda
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.cdcooper = rda.cdcooper
       AND ass.nrdconta = rda.nrdconta
       AND ass.dtdemiss IS NOT NULL
       AND rda.insaqtot = 0
       AND rda.vlsltxmx < 0.01;
    rw_craprda cr_craprda%ROWTYPE;
    
BEGIN
  
FOR rw_crapcop IN cr_crapcop LOOP  
  FOR rw_craprda IN cr_craprda (pr_cdcooper => rw_crapcop.cdcooper) LOOP                                       
                       
    vr_dslog := 'UPDATE cecred.craprda SET insaqtot = '  || rw_craprda.insaqtot ||
                ' vlsdrdca = ' || rw_craprda.vlsdrdca ||
                ' vlsltxmx = ' || rw_craprda.vlsltxmx ||
                ' vlsltxmm = ' || rw_craprda.vlsltxmm ||
                 ' WHERE cdcooper = ' ||rw_craprda.cdcooper ||
                   ' AND nrdconta = '|| rw_craprda.nrdconta ||
                   ' AND nraplica = '|| rw_craprda.nraplica; 
                   
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_tpocorrencia  => 4 
                          ,pr_cdcriticidade => 0 
                          ,pr_tpexecucao    => 3 
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => 'INC0242733'
                          ,pr_cdcooper      =>  rw_craprda.cdcooper
                          ,pr_idprglog      => vr_idprglog);             
    BEGIN
      
     UPDATE CECRED.craprda 
        SET insaqtot = 1,
        vlsdrdca = 0,
        vlsltxmx = 0,
        vlsltxmm = 0
     WHERE cdcooper = rw_craprda.cdcooper
       AND nrdconta = rw_craprda.nrdconta
       AND nraplica = rw_craprda.nraplica;
            
     EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro na CRAPRDA. Erro: ' || SQLERRM;
         RAISE vr_exc_saida;
    END;
   
  END LOOP; 
END LOOP;
 
  COMMIT;  
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      vr_dscritic := nvl(vr_dscritic,' ') || ' - Cooper '|| rw_craprda.cdcooper || ' Conta ' || rw_craprda.nrdconta;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 222
                            ,pr_cdprograma    => 'INC0242733'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK;                        
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' || nvl(vr_dscritic,' ') || ' - Cooper '|| rw_craprda.cdcooper || ' Conta ' || rw_craprda.nrdconta || SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 333
                            ,pr_cdprograma    => 'INC0242733'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK;
         
END;
