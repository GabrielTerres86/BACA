BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     3,
     'CRPS652_CYBER_ENVAILOS+',
     'Caminho arquivo de carga Cyber',
     '/usr/sistemas/recuperacao/cyber/envia');
     COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir registro - '||sqlerrm);
END;
