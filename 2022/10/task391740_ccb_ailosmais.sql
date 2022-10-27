BEGIN
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CCB_AILOSMAIS', 'Ativar convivio do arquivo CCB com ailos+ (1=Ativar, 0=Inativar)', '0');

	COMMIT;
END;
/