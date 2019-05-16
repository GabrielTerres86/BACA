CREATE OR REPLACE PACKAGE CECRED.PAGA_F8N AS
  /* Procedure que prepara retorno para cooperado  */
  PROCEDURE pc_prep_retorno_cooperado_f8n (pr_idregcob IN ROWID      --ROWID da cobranca
                                      ,pr_cdocorre IN INTEGER    --Codigo Ocorrencia
                                      ,pr_dsmotivo IN VARCHAR    --Descricao Motivo
                                      ,pr_dtmvtolt IN DATE       --Data Movimento
                                      ,pr_cdoperad IN VARCHAR2   --Codigo Operador
                                      ,pr_nrremret OUT INTEGER   --Numero Remessa
                                      ,pr_cdcritic OUT INTEGER   --Codigo Critica
                                      ,pr_dscritic OUT VARCHAR2);--Descricao Critica

END PAGA_F8N;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PAGA_F8N AS


  /* Procedure que prepara retorno para cooperado  */
  PROCEDURE pc_prep_retorno_cooperado_f8n (pr_idregcob IN ROWID --ROWID da cobranca
                                      ,pr_cdocorre IN INTEGER --Codigo Ocorrencia
                                      ,pr_dsmotivo IN VARCHAR --Descricao Motivo
                                      ,pr_dtmvtolt IN DATE    --Data Movimento
                                      ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                      ,pr_nrremret OUT INTEGER --Numero Remessa
                                      ,pr_cdcritic OUT INTEGER --Codigo Critica
                                      ,pr_dscritic OUT VARCHAR2) IS --Descricao Critica
   BEGIN
	CECRED.PAGA0001.pc_prep_retorno_cooperado(pr_idregcob, pr_cdocorre, pr_dsmotivo, pr_dtmvtolt, pr_cdoperad, pr_nrremret, pr_cdcritic, pr_dscritic);
   END pc_prep_retorno_cooperado_f8n;

END PAGA_F8N;
/
