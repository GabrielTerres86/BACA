BEGIN
  INSERT INTO cecred.tbgen_batch_jobs
    (nmjob
    ,dsdetalhe
    ,dsprefixo_jobs
    ,idativo
    ,idperiodici_execucao
    ,dsdias_habilitados
    ,dtprox_execucao
    ,flexecuta_feriado
    ,flsaida_email
    ,flsaida_log
    ,dscodigo_plsql
    ,cdoperad_criacao
    ,dtcriacao
    ,flaguarda_processo
    ,flexec_ultimo_dia_ano)
  VALUES
    ('JBRECUPERACAOPEAC'
    ,'Grava parcelas pagas dos contratos do PEAC'
    ,'JBRECUPERACAOPEAC'
    ,1
    ,'D'
    ,'0111110'
    ,to_date('22/10/2023 07:30:00', 'dd/mm/yyyy hh24:mi:ss')
    ,0
    ,'N'
    ,'N'
    ,'BEGIN' || chr(13) || '  recuperacao.incluirRecuperacaoPEAC;' || chr(13) || 'END;'
    ,'1'
    ,SYSDATE
    ,'S'
    ,1);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
