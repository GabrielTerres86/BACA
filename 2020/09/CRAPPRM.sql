BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONSOR_SEQ_REMESSA',
     'Sequancial de remessa do arquivo enviado pela Administradora',
     '6733');
     
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONSOR_SEQ_RETORNO',
     'Sequancial de retorno do arquivo que vamos enviar para Administradora',
     '3405');
     COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir registro - '||sqlerrm);
END;
