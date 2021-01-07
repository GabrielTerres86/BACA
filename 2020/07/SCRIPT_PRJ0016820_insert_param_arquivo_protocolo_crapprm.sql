BEGIN
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'TRAN_BBC_DIR_PRO', 'Diretório do FTP da Transabbc retorno protocolo', '/AGENCIAS/MATR/PROTOCOL');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'TRAN_BBC_USER_PRO', 'Usuario do FTP da Transabbc retorno protocolo', '085');
  
  COMMIT;
END;

