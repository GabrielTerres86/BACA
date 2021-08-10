BEGIN
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'DIR_SCCI_SEGUROS_RECEBE','Diretorio que recebe os arquivos da Prognum','/usr/sistemas/SCCI/Seguros');
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'DIR_SCCI_SEGUROS_RECEBID','Diretorio que possui os arquivos recebidos e processados da Prognum','/usr/sistemas/SCCI');
 COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/