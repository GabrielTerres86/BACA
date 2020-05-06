BEGIN
  DELETE FROM tbcartao_limite_operacional WHERE cdacesso = 'QTD_ERR_EMAIL_BANCOOB';
  
  INSERT INTO tbcartao_limite_operacional (
  nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm
  ) VALUES (
  'CRED'
  ,3
  ,'QTD_ERR_EMAIL_BANCOOB'
  ,'Guarda o limite de envio de email quando ocorre problema na comunicacao com o bancoob. Nova proposta e alteracao limite'
  ,to_char(to_date(TRUNC(SYSDATE), 'DD/MM/RRRR')) || ';0'
  );

  COMMIT;
END;
