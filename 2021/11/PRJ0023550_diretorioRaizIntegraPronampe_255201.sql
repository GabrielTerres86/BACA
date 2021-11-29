BEGIN

  INSERT INTO cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES ('CRED', 0, 'DIR_BB_CONNECTDIRECT', 'Diretório raiz para integração de arquivos com sistemas do Programa Pronampe', '/usr/connect/bb/');

  COMMIT;

END;
