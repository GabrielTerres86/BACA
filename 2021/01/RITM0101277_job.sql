DECLARE
  VR_ERRO EXCEPTION;
  VR_CDCRITIC NUMBER;
  VR_DSCRITIC VARCHAR2(1000);

  CURSOR cr_job IS
    SELECT 1
      FROM tbgen_batch_jobs
     WHERE nmjob = 'JBCYB_ATUALIZA_DADOS_CYBER';
  vr_job cr_job%ROWTYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('SCRIPT "20201210175919332_InserirJobAtualizacaoArquivosCyber" INICIADO EM ' || TO_CHAR(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

  OPEN cr_job;
  FETCH cr_job
    INTO vr_job;

  IF (cr_job%NOTFOUND) THEN
    INSERT INTO tbgen_batch_jobs
      (nmjob
      ,dsdetalhe
      ,dsprefixo_jobs
      ,idativo
      ,idperiodici_execucao
      ,tpintervalo
      ,qtintervalo
      ,dsdias_habilitados
      ,dtprox_execucao
      ,flexecuta_feriado
      ,flsaida_email
      ,dsdestino_email
      ,flsaida_log
      ,dsnome_arq_log
      ,dscodigo_plsql
      ,dtcriacao
      ,flaguarda_processo)
    VALUES
      ('JBCYB_ATUALIZA_DADOS_CYBER'
      ,'Atualizar arquivos de informações para o Cyber'
      ,'JB_CYB_ATU_DADOS'
      ,1
      ,'D'
      ,NULL
      ,NULL
      ,'0111110'
      ,trunc(SYSDATE) + to_dsinterval('0 19:30:00')
      ,0
      ,'N'
      ,NULL
      ,'N'
      ,NULL
      , 'DECLARE
  vr_dscritic VARCHAR2(4000);
BEGIN
  cecred.pc_atualiza_dados_cyber(pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20001, vr_dscritic);
  END IF;
END;'
      ,SYSDATE
      ,'S');
  END IF;
  CLOSE cr_job;

  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('SCRIPT "20201210175919332_InserirJobAtualizacaoArquivosCyber" FINALIZADO COM SUCESSO EM ' || TO_CHAR(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN VR_ERRO THEN
    DBMS_OUTPUT.PUT_LINE('ERRO NA EXECUCAO DO SCRIPT "20201210175919332_InserirJobAtualizacaoArquivosCyber". EXCECAO: ' || TO_CHAR(VR_CDCRITIC) || VR_DSCRITIC);
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, 'ERRO NA EXECUCAO DO SCRIPT "20201210175919332_InserirJobAtualizacaoArquivosCyber". EXCECAO: ' || TO_CHAR(VR_CDCRITIC) || VR_DSCRITIC);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO NAO TRATADO NA EXECUCAO DO SCRIPT "20201210175919332_InserirJobAtualizacaoArquivosCyber" EXCECAO: ' || SUBSTR(SQLERRM, 1, 255));
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002, 'ERRO NAO TRATADO NA EXECUCAO DO SCRIPT. EXCECAO: ' || SUBSTR(SQLERRM, 1, 255));
END;
