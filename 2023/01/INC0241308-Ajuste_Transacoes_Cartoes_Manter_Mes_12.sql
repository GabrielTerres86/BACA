DECLARE
  pr_dtmvtolt  DATE := to_date('01/01/2022', 'dd/mm/rrrr');
  pr_dtmvtolt2 DATE := to_date('30/11/2022', 'dd/mm/rrrr');
  vr_dsjobnam  VARCHAR2(100) := 'JBCRD_IMPORTA_UTLZ_CARTAO - VIA BACA';
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(500);
  vr_exc_erro  EXCEPTION;

  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' 
                                 ,pr_tpocorre IN NUMBER DEFAULT 2 		
                                 ,pr_cdcricid IN NUMBER DEFAULT 2 		
                                 ,pr_tpexecuc IN NUMBER DEFAULT 2 		
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcooper IN VARCHAR2
                                 ,pr_flgsuces IN NUMBER DEFAULT 1 		
                                 ,pr_flabrchd IN INTEGER DEFAULT 0 		
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL
                                 ,pr_flreinci IN INTEGER DEFAULT 0 		
                                  ) IS
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  BEGIN
    CECRED.pc_log_programa(pr_dstiplog           => pr_dstiplog,
                           pr_tpocorrencia       => pr_tpocorre,
                           pr_cdcriticidade      => pr_cdcricid,
                           pr_tpexecucao         => pr_tpexecuc,
                           pr_dsmensagem         => pr_dscritic,
                           pr_cdmensagem         => pr_cdcritic,
                           pr_cdcooper           => NVL(pr_cdcooper, 0),
                           pr_flgsucesso         => pr_flgsuces,
                           pr_flabrechamado      => pr_flabrchd,
                           pr_texto_chamado      => pr_textochd,
                           pr_destinatario_email => pr_desemail,
                           pr_flreincidente      => pr_flreinci,
                           pr_cdprograma         => vr_dsjobnam,
                           pr_idprglog           => vr_idprglog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3);
  END pc_controla_log_batch;

BEGIN
  DELETE tbcrd_utilizacao_cartao c
   WHERE (c.dtmvtolt >= pr_dtmvtolt AND c.dtmvtolt <= pr_dtmvtolt2);

  COMMIT;

  vr_dscritic := 'SUCESSO';
  pc_controla_log_batch(pr_dstiplog => 'F'
                           ,pr_flgsuces => 1
                           ,pr_cdcooper => 0);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  
    vr_dscritic := 'ERRO ' || nvl(vr_dscritic, ' ');
    pc_controla_log_batch(pr_dstiplog => 'O',
                          pr_tpocorre => 4,
                          pr_cdcricid => 0,
                          pr_cdcritic => NVL(vr_cdcritic, 0),
                          pr_dscritic => vr_dscritic,
                          pr_cdcooper => 0,
                          pr_flgsuces => 0);
END;
