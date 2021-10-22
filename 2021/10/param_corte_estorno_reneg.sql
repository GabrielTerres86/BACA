BEGIN
  INSERT INTO crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES 
    ('CRED', 0, 'DTCORTE_ESTORN_RENEG', 'Data de corte para liberação de estornos de renegociações PP', '22/10/2021');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir registro - '||sqlerrm);
END;
