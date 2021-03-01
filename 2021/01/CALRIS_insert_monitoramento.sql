BEGIN  
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',0,'MONITORA_EMAIL_CALRIS','Email de destino dos monitoramentos.','joana.aguida@ailos.coop.br;thiago.rodrigues@ailos.coop.br;renan.oliveira@supero.com.br');
    
  COMMIT;
END;
/