
DECLARE

  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_saida EXCEPTION; 
  vr_dslog        VARCHAR2(4000) := '';
  vr_idprglog NUMBER;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_nrdmsequ INTEGER := 1;
   
  CURSOR cr_crapsli IS
  SELECT nrdconta, cdcooper, (vlsddisp * -1) vlsddisp
    FROM cecred.crapsli
   WHERE vlsddisp < 0
     AND dtrefere = to_date('31/01/2023','dd/mm/yyyy')
   GROUP BY nrdconta, cdcooper, vlsddisp;
     rw_crapsli cr_crapsli%ROWTYPE;

    
BEGIN            

  OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  IF btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE btch0001.cr_crapdat;
    vr_dscritic := 1;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;

  FOR rw_crapsli IN cr_crapsli LOOP           
                             
                       
    vr_dslog := 'UPDATE cecred.crapsli SET vlsddisp = ' || replace(rw_crapsli.vlsddisp, ',', '.') ||
                 ' WHERE CDCOOPER = ' ||rw_crapsli.cdcooper ||
                   ' AND NRDCONTA = '|| rw_crapsli.nrdconta ||
                   ' AND DTREFERE = TO_DATE(''31/01/2023'',''DD/MM/YYYY'');'; 
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_tpocorrencia  => 4 
                          ,pr_cdcriticidade => 0 
                          ,pr_tpexecucao    => 3 
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => 'INC0240008'
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);             
    BEGIN
      INSERT INTO
        cecred.craplci(cdcooper
                      ,dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrdconta
                      ,nrdocmto
                      ,nrseqdig
                      ,vllanmto
                      ,cdhistor)
                VALUES(rw_crapsli.cdcooper
                      ,rw_crapdat.dtmvtolt
                      ,1
                      ,100
                      ,8599
                      ,rw_crapsli.nrdconta
                      ,vr_nrdmsequ
                      ,vr_nrdmsequ
                      ,rw_crapsli.vlsddisp
                      ,4133);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro na CRAPLCI. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
    END;
    BEGIN
      UPDATE cecred.crapsli
         SET vlsddisp = vlsddisp + rw_crapsli.vlsddisp
       WHERE cdcooper = rw_crapsli.cdcooper
         AND nrdconta = rw_crapsli.nrdconta
         AND dtrefere = to_date('31/01/2023','dd/mm/yyyy');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro na CRAPSLI. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
    END;       
    vr_nrdmsequ := vr_nrdmsequ + 1;
  END LOOP;      
  COMMIT;   
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      vr_dscritic := nvl(vr_dscritic,' ') || 
                    ' - Cooper '|| rw_crapsli.cdcooper || ' Conta ' || rw_crapsli.nrdconta;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 222
                            ,pr_cdprograma    => 'INC0240008'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK;                        
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' ||
                      nvl(vr_dscritic,' ') || ' - Cooper '|| rw_crapsli.cdcooper || ' Conta ' || rw_crapsli.nrdconta ||
                      SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_tpocorrencia  => 4 
                            ,pr_cdcriticidade => 0 
                            ,pr_tpexecucao    => 3 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 333
                            ,pr_cdprograma    => 'INC0240008'
                            ,pr_cdcooper      => 3 
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK;
END;
