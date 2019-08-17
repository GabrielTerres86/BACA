-- Cancelamento de Protesto
declare
  vr_dscritic varchar2(2000);
  vr_dserro   varchar2(2000);
  CURSOR cr_crapcob is
    select rowid, cdcooper, nrdconta, nrcnvcob, nrdocmto
      from crapcob
     where  (cdcooper, nrdconta, nrcnvcob, nrdocmto) in (
                                                         (2,512001,102002,1253),
                                                         (5,126063,104002,189),
                                                         (5,145947,104001,29),
                                                         (5,156388,104002,26),
                                                         (7,167029,106002,34),
                                                         (9,14184,10860,462),
                                                         (9,24341,108004,8702),
                                                         (9,24341,108004,8704),
                                                         (9,147273,108002,1606),
														 (9,6378,10811,174570),
														 (9,167215,108004,1000092),
                                                         (9,202924,108002,212),
                                                         (9,206083,108002,60),
                                                         (9,905534,10880,3359),
                                                         (9,905534,10880,3373),
                                                         (12,47406,111004,7188),
                                                         (12,62715,111050,404),
                                                         (13,5070,112001,71),
                                                         (13,5070,112001,79),
                                                         (13,5070,112002,2130),
														                             (13,163317,112001,28), --negativacao
                                                         (13,11940,112002,1343),
                                                         (13,239976,112002,362),
                                                         (13,239976,112002,364),
                                                         (14,1961,113002,1919),
                                                         (14,6130,113002,323),
                                                         (14,91685,113002,189),
                                                         (16,243590,115090,178),
                                                         (16,286435,115002,253)
                                                        );
begin
  FOR rw_crapcob in cr_crapcob LOOP
    update crapcob
       set insitcrt = 0,
           dtsitcrt = null
     where cdcooper = rw_crapcob.cdcooper
       and nrdconta = rw_crapcob.nrdconta
       and nrcnvcob = rw_crapcob.nrcnvcob
       and nrdocmto = rw_crapcob.nrdocmto;
      --Cria log no boleto
    paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid 
                                , pr_cdoperad => '1' 
                                , pr_dtmvtolt => trunc(SYSDATE) 
                                , pr_dsmensag => 'Protesto cancelado manualmente' 
                                , pr_des_erro => vr_dserro 
                                , pr_dscritic => vr_dscritic );
                                
    COMMIT;
  END LOOP;
  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      cecred.pc_internal_exception;
END;
