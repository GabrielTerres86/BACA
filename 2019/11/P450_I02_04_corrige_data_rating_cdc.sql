DECLARE
  CURSOR cr_rating_efetivar IS
    SELECT e.cdcooper,
             e.nrdconta,
             e.nrctremp,
             o.tpctrato,
             e.dtmvtolt,
             e.cdopeefe,
             d.dtmvtolt as dtcooper
        FROM crapepr e,
             crapdat d,
             tbrisco_operacoes o
       WHERE e.cdcooper = o.cdcooper
         AND e.nrdconta = o.nrdconta
         AND e.nrctremp = o.nrctremp
         AND d.cdcooper = o.cdcooper
         AND o.dtrisco_rating < to_date('01/01/1000','dd/mm/yyyy');

  vr_exc_erro EXCEPTION;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);
BEGIN
  FOR rw_rating_efetivar IN cr_rating_efetivar LOOP
    rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_rating_efetivar.cdcooper,
                                      pr_nrdconta          => rw_rating_efetivar.nrdconta,
                                      pr_nrctrato          => rw_rating_efetivar.nrctremp,
                                      pr_tpctrato          => rw_rating_efetivar.tpctrato,
                                      pr_strating          => 4,
                                      pr_dtrating          => rw_rating_efetivar.dtmvtolt,
                                      pr_justificativa     => 'SCRIPT Correção data efetivação de contratos via IB/CDC sem endividamento',
                                      pr_tpoperacao_rating => 2,
                                      pr_cdoperad          => rw_rating_efetivar.cdopeefe,
                                      pr_dtmvtolt          => rw_rating_efetivar.dtcooper,
                                      pr_cdcritic          => vr_cdcritic,
                                      pr_dscritic          => vr_dscritic);
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      vr_dscritic := 'Erro pc_grava_rating_operacao [' ||
                     rw_rating_efetivar.cdcooper || '|' ||
                     rw_rating_efetivar.nrdconta || '|' ||
                     rw_rating_efetivar.nrctremp || '|' ||
                     rw_rating_efetivar.tpctrato || '|' ||
                     SYSDATE                     || '|' ||
                     vr_cdcritic || '|' ||
                     vr_dscritic || '] => ' || SQLERRM;
      RAISE vr_exc_erro;
    END IF;
  
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line(vr_dscritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                               pr_ind_tipo_log => 1,
                               pr_des_log      => vr_dscritic,
                               pr_dstiplog     => NULL,
                               pr_nmarqlog     => 'corrige_data_rating_cdc',
                               pr_cdprograma   => 'DATRAT',
                               pr_tpexecucao   => 2);
  WHEN OTHERS THEN
    ROLLBACK;
    vr_dscritic := 'Erro geral operacões sem rating. Erro: ' || SQLERRM;
    dbms_output.put_line(vr_dscritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                               pr_ind_tipo_log => 1,
                               pr_des_log      => vr_dscritic,
                               pr_dstiplog     => NULL,
                               pr_nmarqlog     => 'corrige_data_rating_cdc',
                               pr_cdprograma   => 'DATRAT',
                               pr_tpexecucao   => 2);
END;
