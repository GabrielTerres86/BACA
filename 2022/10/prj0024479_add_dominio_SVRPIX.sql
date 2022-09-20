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
  VALUES ('SITDEVPIX_COMPLETA' ,'5', 'Aguardando confirmação Pix');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'6', 'Pix não confirmado, necessário validação manual');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'7', 'Processado com Sucesso');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'8', 'Processado com Falha');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'9', 'Rejeitado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPLETA' ,'10', 'Resolvido Manualmente');
  
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
  VALUES ('SITDEVPIX_RESUMO' ,'5', 'Aguardando confirmação Pix');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'6', 'Pix não confirmado, validar manualmente');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'7', 'Processado com sucesso');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'8', 'Processado com falha');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'9', 'Rejeitado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_RESUMO' ,'10', 'Resolvido Manualmente');
  
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
  VALUES ('SITDEVPIX_COMPACTO' ,'5', 'Aguardando confirmação Pix');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'6', 'Pix não confirmado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'7', 'Processado com sucesso');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'8', 'Processado com falha');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'9', 'Rejeitado');
  INSERT INTO CECRED.TBCC_DOMINIO_CAMPO T (nmdominio, cddominio, dscodigo)
  VALUES ('SITDEVPIX_COMPACTO' ,'10', 'Resolvido Manualmente');
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
