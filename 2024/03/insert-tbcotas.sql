
DECLARE
  vr_cdprograma VARCHAR2(50) := 'SCRIPT-COTAS';
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_exc_saida  EXCEPTION; 
  vr_idprglog   NUMBER;
  vr_qtdregis   INTEGER := 0;
  vr_cdcritic   pls_integer;
  rw_crapdat    btch0001.cr_crapdat%rowtype;
   
  CURSOR cr_crappla IS
    select pla.cdcooper,
           pla.nrdconta,
           pla.nrctrpla,
           pla.dtdpagto,
           pla.vlpenden
     from cecred.crappla pla
    where cdsitpla = 1
      and vlpenden > 0
      and tpdplano = 1
      and flgpagto = 0;
    
BEGIN            
   CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => 'INICIO',
                             pr_cdmensagem => 111,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);                                               

  FOR rw_crappla IN cr_crappla LOOP           
    
    BEGIN
     insert into INVESTIMENTO.TB_COTA_PENDENTE
                      (cdcooper,
                       nrdconta,
                       nrctrpla,
                       vlpenden,
                       dteimosa)
                    values
                      (rw_crappla.cdcooper,
                       rw_crappla.nrdconta,
                       rw_crappla.nrctrpla,
                       rw_crappla.vlpenden,
                       rw_crappla.dtdpagto);
      EXCEPTION
      WHEN OTHERS THEN
      vr_dscritic := 'Erro ao iserir tbcotas. Detalhes: '||SQLERRM;
      RAISE vr_exc_saida;
    END;    
    
    vr_qtdregis := vr_qtdregis + 1;
    IF MOD(vr_qtdregis, 10000) = 0 THEN
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_dsmensagem    => 'Commit - ' || vr_qtdregis
                            ,pr_cdmensagem    => 222
                            ,pr_cdprograma    => vr_cdprograma
                            ,pr_cdcooper      => 3
                            ,pr_idprglog      => vr_idprglog);
      COMMIT;
    END IF;
  END LOOP;      
  
  COMMIT;   
  
  EXCEPTION
    WHEN vr_exc_saida THEN
     CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;                        
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' || SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 444,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;
END;
