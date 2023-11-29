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
    ,'SAQPAG_NOVO_CORE'
    ,'Identifica se o Novo Core esta habilitado (1-Ailos+ / 0-Aimaro)'
    ,'0');

  COMMIT;

END;
