BEGIN

  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'SAQPAG_TEMPO_JOB'
    ,'Saque & Pague - Tempo para reagendamento do JOB (em minutos)'
    ,'10');

  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'SAQPAG_QTD_JOB_EXEC'
    ,'Saque & Pague - Controle de execuções do re-agendamento'
    ,'0');

  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'SAQPAG_QTD_JOB_AGENDA'
    ,'Saque & Pague - Quantidade de re-agendamentos da concilicação'
    ,'5');

  COMMIT;
END;
