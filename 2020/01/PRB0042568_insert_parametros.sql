BEGIN

  INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'BAIXA_OPERAC_BULK',
     'Parametro do bulk collect da baixa operacional',
     '5000');

  INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'BAIXA_OPERAC_EMAIL',
     'Parametro de email para envio de erros e avisos da baixa operacional',
     'cobranca@ailos.coop.br');

  INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'BAIXA_OPERAC_TEMP_LIM',
     'Parametro de tempo limite para execucao da baixa operacional (em minutos)',
     '1');

  INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'BAIXA_EFETIV_BULK',
     'Parametro do bulk collect da baixa efetiva',
     '5000');
	 
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION(PR_COMPLEME => 'PRB0042568');
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
	ROLLBACK;
END;
