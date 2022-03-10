BEGIN
  INSERT INTO tbgen_batch_jobs
    (NMJOB
    ,DSDETALHE
    ,DSPREFIXO_JOBS
    ,IDATIVO
    ,IDPERIODICI_EXECUCAO
    ,TPINTERVALO
    ,QTINTERVALO
    ,DSDIAS_HABILITADOS
    ,DTPROX_EXECUCAO
    ,FLEXECUTA_FERIADO
    ,FLSAIDA_EMAIL
    ,DSDESTINO_EMAIL
    ,FLSAIDA_LOG
    ,DSNOME_ARQ_LOG
    ,DSCODIGO_PLSQL
    ,CDOPERAD_CRIACAO
    ,DTCRIACAO
    ,CDOPERAD_ALTERACAO
    ,DTALTERACAO
    ,HRJANELA_EXEC_INI
    ,HRJANELA_EXEC_FIM
    ,FLAGUARDA_PROCESSO
    ,FLEXEC_ULTIMO_DIA_ANO)
  VALUES
    ('JBRECUP_PEAC'
    ,'Job responsavel por gerar a movimentacao financeira no recebimento de honra PEAC'
    ,'JBRECUP_PEAC'
    ,1
    ,'D'
    ,NULL
    ,NULL
    ,'0111110'
    ,to_date('11-03-2022 12:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0
    ,'N'
    ,NULL
    ,'N'
    ,NULL
    , 'BEGIN
RECUPERACAO.gerarMovimentacaoFinancPeacJob;
END;'
    ,'1'
    ,to_date('10-03-2022 14:40:41', 'dd-mm-yyyy hh24:mi:ss')
    ,'1'
    ,to_date('10-03-2022 15:13:05', 'dd-mm-yyyy hh24:mi:ss')
    ,NULL
    ,NULL
    ,'S'
    ,0);
  COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;--NÃO FAZ NADA
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao gravar job peac. Erro: ' || SQLERRM);
    ROLLBACK;
END;
