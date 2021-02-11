BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONSOR_SEQ_REMESSA',
     'Sequancial de remessa do arquivo enviado pela Administradora',
     '6796');
     
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONSOR_SEQ_RETORNO',
     'Sequancial de retorno do arquivo que vamos enviar para Administradora',
     '1');
	 
  INSERT INTO crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES 
    ('CRED', 0, 'DIR_658_ENVIA', 'Diretorio que enviar os arquivos de convenios', '/usr/connect/sicredi/envia');

  INSERT INTO crapprm 
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED', 0, 'DIR_658_ENVIADOS', 'Diretorio que possui os arquivos enviados e processados dos convenios', '/usr/connect/sicredi/enviados');
	
     COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir registro - '||sqlerrm);
END;
