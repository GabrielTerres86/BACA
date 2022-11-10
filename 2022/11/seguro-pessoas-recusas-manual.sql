 
BEGIN

DECLARE

vr_cdcritic           PLS_INTEGER;
vr_dscritic           VARCHAR2(4000);
vr_exc_erro           EXCEPTION;  
vr_idprglog 		  CECRED.tbgen_prglog.idprglog%TYPE := 0;

BEGIN

   cecred.pc_integra_recusa_contributario(pr_cdcritic => vr_cdcritic,
										  pr_dscritic => vr_dscritic);



  IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  COMMIT;
  
EXCEPTION
    WHEN vr_exc_erro THEN
      CECRED.pc_log_programa(pr_dstiplog => 'O'
                            ,pr_tpocorrencia => 4
                            ,pr_cdcriticidade => vr_cdcritic
                            ,pr_cdcooper => 3
                            ,pr_dsmensagem => cecred.gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' - Processar arquivos de recusa do seguro prestamista Contributario. script'
                            ,pr_cdmensagem => vr_cdcritic
                            ,pr_cdprograma => 'JB_ARQPRST'
                            ,pr_idprglog => vr_idprglog
                            ,pr_tpexecucao => 2);
END;

END;
