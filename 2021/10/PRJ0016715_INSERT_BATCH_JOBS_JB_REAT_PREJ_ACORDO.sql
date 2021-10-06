DECLARE
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);

  CURSOR cr_job IS
    SELECT 1 FROM tbgen_batch_jobs WHERE nmjob = 'JB_REAT_PREJ_ACORDO';
  vr_job cr_job%ROWTYPE;
BEGIN
  dbms_output.put_line('SCRIPT INICIADO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

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
      ('JB_REAT_PREJ_ACORDO'
      ,'PROCESSAR REATIVACAO DE PREJUIZO - ACORDO'
      ,'JB_REA_PRJ_ACO'
      ,1
      ,'D'
      ,NULL
      ,NULL
      ,'0111110'
      ,trunc(SYSDATE) + to_dsinterval('0 09:30:00')
      ,0
      ,'N'
      ,NULL
      ,'N'
      ,NULL
      , 'DECLARE
  vr_dscritic VARCHAR2(4000);
BEGIN
  cecred.pc_crps754(pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20001, vr_dscritic);
  END IF;
END;'
      ,SYSDATE
      ,'S');
  END IF;
  CLOSE cr_job;

  COMMIT;

  dbms_output.put_line('SCRIPT FINALIZADO COM SUCESSO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('ERRO NAO TRATADO NA EXECUCAO DO SCRIPT EXCECAO: ' ||
                         substr(SQLERRM, 1, 255));
    ROLLBACK;
    raise_application_error(-20002,
                            'ERRO NAO TRATADO NA EXECUCAO DO SCRIPT. EXCECAO: ' ||
                            substr(SQLERRM, 1, 255));
END;
