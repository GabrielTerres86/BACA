BEGIN
  INSERT INTO crapprm(nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) VALUES ('CRED',0,'DIR_SCCI_SEGUROS_ERRO', 'Diretorio que possui os arquivos recebidos e processados com erro da Prognum','/usr/sistemas/SCCI/Seguros/Erro');
  
  UPDATE crapprm c
     SET c.dsvlrprm = '/usr/sistemas/SCCI/Seguros/Sucesso'
   WHERE c.cdacesso = 'DIR_SCCI_SEGUROS_RECEBID';
 COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
