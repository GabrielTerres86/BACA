-- Protesto
declare 
  vr_cdcritic varchar2(200);
  vr_dscritic varchar2(2000);
  vr_dserro   varchar2(2000);
  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  
  CURSOR cr_crapcob is 
    select rowid, cdcooper, nrdconta, nrcnvcob, nrdocmto
      from crapcob
     where (cdcooper, nrdconta, nrcnvcob, nrdocmto) in ((5,156183,104001,129),
                                                        (5,156183,104001,132),
                                                        (6,500658,105080,776),
                                                        (7,92878,106002,26),
                                                        (7,114561,106080,260),
                                                        (8,36706,107001,40),
                                                        (9,795,10870,1345),
                                                        (9,795,10870,1346),
                                                        (9,795,10870,1347),
                                                        (9,795,10870,1348),
                                                        (9,21830,10811,1682),
                                                        (10,42340,109050,701),
                                                        (10,42340,109050,705),
                                                        (10,103209,110004,7682),
                                                        (13,86444,112004,364774),
                                                        (13,160067,112001,627),
                                                        (13,160067,112001,635),
                                                        (14,6130,113002,326),
                                                        (16,134929,11530,1743),
                                                        (16,223883,115090,62)
                                                       );
begin
  FOR rw IN cr_crapcob LOOP 
    --Retira o protesto para depois protestar novamente
    UPDATE crapcob
       SET insitcrt = 0,
           dtsitcrt = null
     WHERE cdcooper = rw.cdcooper
       AND nrdconta = rw.nrdconta
       AND nrcnvcob = rw.nrcnvcob
       AND nrdocmto = rw.nrdocmto;
       
    --Realiza o protesto
    cobr0007.pc_inst_protestar(pr_cdcooper => rw.cdcooper
                             , pr_nrdconta => rw.nrdconta
                             , pr_nrcnvcob => rw.nrcnvcob
                             , pr_nrdocmto => rw.nrdocmto
                             , pr_cdocorre => '09'
                             , pr_cdtpinsc => 0 -- variavel nao esta sendo utilizada
                             , pr_dtmvtolt => sysdate
                             , pr_cdoperad => 1
                             , pr_nrremass => 0
                             , pr_tab_lat_consolidada => vr_tab_lat_consolidada
                             , pr_cdcritic => vr_cdcritic
                             , pr_dscritic => vr_dscritic);
    --Cria log no boleto
    paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid 
                                , pr_cdoperad => '1' 
                                , pr_dtmvtolt => trunc(SYSDATE) 
                                , pr_dsmensag => 'Titulo protestado manualmente' 
                                , pr_des_erro => vr_dserro 
                                , pr_dscritic => vr_dscritic ); 

    COMMIT; 
  END LOOP; 

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      cecred.pc_internal_exception;
END;
