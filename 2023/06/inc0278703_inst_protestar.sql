declare 
  vr_cdcritic varchar2(200);
  vr_dscritic varchar2(2000);
  vr_dserro   varchar2(2000);
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  
  CURSOR cr_crapcob is 
    select rowid, cdcooper, nrdconta, nrcnvcob, nrdocmto
      from crapcob
     WHERE crapcob.cdcooper > 0
       AND trunc(dtvencto + qtdiaprt) BETWEEN 
           to_date('20/05/2023','DD/MM/RRRR') AND to_date('26/06/2023','DD/MM/RRRR')
       AND crapcob.incobran = 0
       AND crapcob.insitcrt = 0
       AND crapcob.qtdiaprt > 0
       AND nvl(crapcob.flgdprot, 0) = 1;

begin
  FOR rw IN cr_crapcob LOOP 
       
    cobr0007.pc_inst_protestar(pr_cdcooper => rw.cdcooper
                             , pr_nrdconta => rw.nrdconta
                             , pr_nrcnvcob => rw.nrcnvcob
                             , pr_nrdocmto => rw.nrdocmto
                             , pr_cdocorre => '09'
                             , pr_cdtpinsc => 0
                             , pr_dtmvtolt => trunc(SYSDATE)
                             , pr_cdoperad => 1
                             , pr_nrremass => 0
                             , pr_tab_lat_consolidada => vr_tab_lat_consolidada
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);
                             
    IF vr_dscritic IS NULL OR nvl(vr_cdcritic,0) = 0 THEN

       paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                   , pr_cdoperad => '1' 
                                   , pr_dtmvtolt => trunc(SYSDATE) 
                                   , pr_dsmensag => 'Solicitação de protesto manualmente'
                                   , pr_des_erro => vr_dserro 
                                   , pr_dscritic => vr_dscritic ); 
    ELSE

       IF nvl(vr_cdcritic,0) > 0 THEN
          vr_dscritic := 'Erro ao solicitar protesto: ' || gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       
       paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                   , pr_cdoperad => '1' 
                                   , pr_dtmvtolt => trunc(SYSDATE) 
                                   , pr_dsmensag => vr_dscritic
                                   , pr_des_erro => vr_dserro 
                                   , pr_dscritic => vr_dscritic );      
    END IF;

    COMMIT; 
  END LOOP; 

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0278703');
END;