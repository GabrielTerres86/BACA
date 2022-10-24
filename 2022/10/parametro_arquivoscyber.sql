BEGIN
  BEGIN
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CRPS652_CYBER_CONTACTR', 'Indica se irá gerar dados da conta e contrato em posições maiores', 'S');
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
	  NULL;
  END;
  COMMIT;
END;
