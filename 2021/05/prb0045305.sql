BEGIN

  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  values ('CRED',0,'QT_ENVIOCNSJD','Quantidade de execução da job de envio de consultas JD',31);

  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  values ('CRED',0,'QT_COMMITLOTEJD','Quantidade de execuções entre o commit na consulta em lote com a JD',100);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna;
    ROLLBACK;
END;