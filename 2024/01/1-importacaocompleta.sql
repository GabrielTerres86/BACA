declare 
  pr_dtfevereiro date := to_date('28/02/2023','dd/mm/rrrr');
  pr_dtjulho     date := to_date('31/07/2023','dd/mm/rrrr');
  pr_dtsetembro  date := to_date('30/09/2023','dd/mm/rrrr');
  pr_dtoutubro   date := to_date('31/10/2023','dd/mm/rrrr');
  pr_dtnovembro  date := to_date('30/11/2023','dd/mm/rrrr');
  pr_dtdezembro  date := to_date('31/12/2023','dd/mm/rrrr');
  vr_cdprograma  VARCHAR2(100):= 'JBCRD_IMPORTA_UTLZ_CARTAO';
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  vn_contador NUMBER := 0;

  TYPE typ_reg_utlz_crd IS
    RECORD(dtmvtolt         tbcrd_intermed_utlz_cartao.dtmvtolt%TYPE
           ,nrconta_cartao   tbcrd_intermed_utlz_cartao.nrconta_cartao%TYPE
           ,qttransa_debito  tbcrd_intermed_utlz_cartao.qttransa_debito%TYPE
           ,qttransa_credito tbcrd_intermed_utlz_cartao.qttransa_credito%TYPE
           ,vltransa_debito  tbcrd_intermed_utlz_cartao.vltransa_debito%TYPE
           ,vltransa_credito tbcrd_intermed_utlz_cartao.vltransa_credito%TYPE); 
  TYPE typ_tab_utlz_crd IS
    TABLE OF typ_reg_utlz_crd;
    
  TYPE typ_reg_conta_crd IS
    RECORD(cdcooper        crapass.cdcooper%TYPE
           ,nrdconta        crapass.nrdconta%TYPE); 
  TYPE typ_tab_conta_crd IS
    TABLE OF typ_reg_conta_crd INDEX BY VARCHAR2(15);

  vr_tab_utlz_crd  typ_tab_utlz_crd;
  vr_tab_conta_crd typ_tab_conta_crd;     
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(500);
  vr_exc_erro  EXCEPTION;
     
  CURSOR cr_intermedcrd IS
    SELECT inmedcrd.dtmvtolt
           ,inmedcrd.nrconta_cartao
           ,inmedcrd.qttransa_debito
           ,inmedcrd.qttransa_credito
           ,inmedcrd.vltransa_debito
           ,inmedcrd.vltransa_credito
    FROM cecred.tbcrd_intermed_utlz_cartao inmedcrd
    WHERE inmedcrd.dtmvtolt = pr_dtfevereiro OR
          inmedcrd.dtmvtolt = pr_dtjulho     OR
          inmedcrd.dtmvtolt = pr_dtsetembro  OR
          inmedcrd.dtmvtolt = pr_dtoutubro   OR
          inmedcrd.dtmvtolt = pr_dtnovembro  OR
          inmedcrd.dtmvtolt = pr_dtdezembro;

  CURSOR cr_contacrd IS
    SELECT tbcc.cdcooper
           ,tbcc.nrdconta
           ,tbcc.nrconta_cartao
    FROM cecred.tbcrd_conta_cartao tbcc;
  rw_contacrd cr_contacrd%ROWTYPE;

BEGIN  
  
  BEGIN
    DELETE cecred.tbcrd_utilizacao_cartao utlz
     WHERE utlz.dtmvtolt = pr_dtfevereiro OR
           utlz.dtmvtolt = pr_dtjulho     OR
           utlz.dtmvtolt = pr_dtsetembro  OR
           utlz.dtmvtolt = pr_dtoutubro   OR
           utlz.dtmvtolt = pr_dtnovembro  OR
           utlz.dtmvtolt = pr_dtdezembro;
    EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 111,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);                                               
                 
  END;  

  OPEN  cr_intermedcrd;
  FETCH cr_intermedcrd BULK COLLECT INTO vr_tab_utlz_crd;     
  CLOSE cr_intermedcrd;

  FOR rw_contacrd IN cr_contacrd LOOP
    vr_tab_conta_crd(rw_contacrd.nrconta_cartao).cdcooper := rw_contacrd.cdcooper;
    vr_tab_conta_crd(rw_contacrd.nrconta_cartao).nrdconta := rw_contacrd.nrdconta;                  
  END LOOP;
   
  IF vr_tab_utlz_crd.COUNT = 0 THEN
    vr_dscritic := 'Sem dados para importacao!';
    raise vr_exc_erro;
  ELSE
    FOR idx IN vr_tab_utlz_crd.FIRST .. vr_tab_utlz_crd.LAST LOOP             
      IF vr_tab_conta_crd.EXISTS(vr_tab_utlz_crd(idx).nrconta_cartao) = FALSE THEN                     
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 'Nr Conta Cartao = ' || vr_tab_utlz_crd(idx).nrconta_cartao;                        
        CECRED.pc_log_programa(pr_dstiplog   => 'O',
                               pr_dsmensagem => vr_dscritic,
                               pr_cdmensagem => 222,
                               pr_cdprograma => vr_cdprograma,
                               pr_cdcooper   => 3,
                               pr_idprglog   => vr_idprglog);                                 
        CONTINUE;
      END IF;
             
      BEGIN
        INSERT 
          INTO cecred.tbcrd_utilizacao_cartao (dtmvtolt
                                       ,nrconta_cartao
                                       ,cdcooper
                                       ,nrdconta
                                       ,qttransa_debito
                                       ,qttransa_credito
                                       ,vltransa_debito
                                       ,vltransa_credito
                              ) VALUES (vr_tab_utlz_crd(idx).dtmvtolt
                                       ,vr_tab_utlz_crd(idx).nrconta_cartao
                                       ,vr_tab_conta_crd(vr_tab_utlz_crd(idx).nrconta_cartao).cdcooper
                                       ,vr_tab_conta_crd(vr_tab_utlz_crd(idx).nrconta_cartao).nrdconta
                                       ,vr_tab_utlz_crd(idx).qttransa_debito
                                       ,vr_tab_utlz_crd(idx).qttransa_credito
                                       ,vr_tab_utlz_crd(idx).vltransa_debito
                                       ,vr_tab_utlz_crd(idx).vltransa_credito);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              vr_cdcritic := 285;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 'Nr Conta Cartao = ' || vr_tab_utlz_crd(idx).nrconta_cartao;
              CECRED.pc_log_programa(pr_dstiplog   => 'O',
                                     pr_dsmensagem => vr_dscritic,
                                     pr_cdmensagem => 333,
                                     pr_cdprograma => vr_cdprograma,
                                     pr_cdcooper   => 3,
                                     pr_idprglog   => vr_idprglog);              
                    
            WHEN OTHERS THEN
              vr_cdcritic := 9999;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || SQLERRM;
              CECRED.pc_log_programa(pr_dstiplog   => 'O',
                                     pr_dsmensagem => vr_dscritic,
                                     pr_cdmensagem => 444,
                                     pr_cdprograma => vr_cdprograma,
                                     pr_cdcooper   => 3,
                                     pr_idprglog   => vr_idprglog);                                               
                 
       END; 
       IF vn_contador >= 5000 then
         vn_contador := 0;
         COMMIT;
       END IF;
       vn_contador := vn_contador + 1;             
     END LOOP;
   END IF;
   
   COMMIT;
     
     vr_dscritic := 'SUCESSO';
   
     CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 555,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);     
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;        
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 666,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);
  WHEN OTHERS THEN
    ROLLBACK;
    vr_dscritic := 'ERRO ' ||nvl(vr_dscritic,' ');      
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 777,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);    
end;
