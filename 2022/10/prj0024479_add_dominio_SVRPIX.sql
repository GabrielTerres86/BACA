BEGIN

  DELETE CECRED.TBCC_DOMINIO_CAMPO T WHERE t.nmdominio = 'SITDEVPIX_COMPLETA';
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'1', 'Inserido e aguardando transferencia para Conta Administrativa');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'2', 'Pendente de análise');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'3', 'Aprovado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'4', 'Transferência para Conta Administrativa realizada, aguardando envio Pix');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'5', 'Processado com sucesso');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'6', 'Processado com falha');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'7', 'Rejeitado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'8', 'Resolvido Manualmente');
  
  DELETE CECRED.TBCC_DOMINIO_CAMPO T WHERE t.nmdominio = 'SITDEVPIX_RESUMO';
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'1', 'Aguardando transferência Conta Administrativa');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'2', 'Pendente de análise');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'3', 'Aprovado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'4', 'Aguardando envio Pix');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'5', 'Processado com sucesso');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'6', 'Processado com falha');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'7', 'Rejeitado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'8', 'Resolvido Manualmente');
  
  DELETE CECRED.TBCC_DOMINIO_CAMPO T WHERE t.nmdominio = 'SITDEVPIX_COMPACTO';
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'1', 'Aguardando transferência');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'2', 'Pendente de análise');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'3', 'Aprovado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'4', 'Aguardando Pix');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'5', 'Processado com sucesso');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'6', 'Processado com falha');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'7', 'Rejeitado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'8', 'Resolvido Manualmente');
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
