declare 
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic varchar2(5000) := ' ';
  vr_excsaida EXCEPTION;
  loga        varchar2(5000) := ' ';
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  vr_cdprograma  VARCHAR2(100):= 'JBCRD_IMPORTA_UTLZ_CARTAO2';
  
  cursor cr_crapcar IS
     SELECT crd.rowid, crd.nrconta_cartao, crd.dtmvtolt, crd.cdcooper, crd.nrdconta, 
           (select car.cdcooper from tbcrd_conta_cartao car where  crd.nrconta_cartao = car.nrconta_cartao) coop_certa,
           (select car.nrdconta from tbcrd_conta_cartao car where crd.nrconta_cartao = car.nrconta_cartao) conta_certa,
           crd.qttransa_debito, crd.qttransa_credito, crd.vltransa_debito, crd.vltransa_credito 
    from tbcrd_utilizacao_cartao crd
    where not exists(Select 1 from tbcrd_conta_cartao car where crd.cdcooper = car.cdcooper and crd.nrdconta = car.nrdconta and crd.nrconta_cartao = car.nrconta_cartao)
          and crd.dtmvtolt between to_date('01/01/2023','dd/mm/yyyy')  AND to_date('31/12/2023','dd/mm/yyyy');
  rw_crapcar cr_crapcar%ROWTYPE;

  vr_vlsppant_correto craprpp.vlsppant%TYPE;

 
BEGIN

  CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => 'INICIO',
                             pr_cdmensagem => 111,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);  
  FOR rw_crapcar IN cr_crapcar LOOP
  
    loga := 'Ajustando a conta ao cartão: Cooper Associada: '|| rw_crapcar.cdcooper || 
                                         ' Cooper Correta: '  || rw_crapcar.coop_certa ||
                                         ' Conta Associada: ' || rw_crapcar.nrdconta ||
                                         ' Conta Correta: '   || rw_crapcar.conta_certa;
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => loga,
                             pr_cdmensagem => 222,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);
 
    
    loga := 'update tbcrd_utilizacao_cartao set nrdconta = '|| rw_crapcar.nrdconta || ', cdcooper = ' || rw_crapcar.cdcooper ||
           ' where tbcrd_utilizacao_cartao.rowid = '''|| rw_crapcar.rowid ||''';'; 
     CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => loga,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);   
    
    BEGIN
      UPDATE tbcrd_utilizacao_cartao
         SET nrdconta      = rw_crapcar.conta_certa,
             cdCooper      = rw_crapcar.coop_certa
       WHERE tbcrd_utilizacao_cartao.rowid = rw_crapcar.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := ' Erro atualizando tbcrd_utilizacao_cartao!' || 
                       ' Cooper Associada: '|| rw_crapcar.cdcooper || 
                       ' Cooper Correta: '  || rw_crapcar.coop_certa ||
                       ' Conta Associada: ' || rw_crapcar.nrdconta ||
                       ' Conta Correta: '   || rw_crapcar.conta_certa || ' SQLERRM: ' || SQLERRM;
        
        RAISE vr_excsaida;
    END;

  END LOOP;
  
  COMMIT;

   CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => 'FIM',
                             pr_cdmensagem => 444,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);
  
EXCEPTION
  WHEN vr_excsaida then 
    vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
     CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 555,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
    
  WHEN OTHERS then
    vr_dscritic := 'ERRO ' || vr_dscritic || SQLERRM;
    rollback;
     CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 666,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
end;
