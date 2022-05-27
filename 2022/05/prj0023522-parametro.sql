BEGIN

	INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
                 VALUES ('CRED', 0, 'MLC_ATIVO', 'MLC Ativa', 'S');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
  
END;