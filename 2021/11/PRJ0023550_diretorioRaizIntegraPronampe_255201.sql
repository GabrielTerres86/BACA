BEGIN

  INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 0, 'DIR_BB_CONNECTDIRECT', 'Diret�rio raiz para integra��o de arquivos com sistemas do Programa Pronampe', '/usr/connect/bb/');

  COMMIT;

END;
