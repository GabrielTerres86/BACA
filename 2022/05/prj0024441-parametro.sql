BEGIN

	INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
                 VALUES ('CRED', 0, 'MLC_ATIVO', 'Flag que determina se o fluxo de moderniza��o de liquida��o da cobran�a (MLC) est� ativo', 'S');

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');

END;