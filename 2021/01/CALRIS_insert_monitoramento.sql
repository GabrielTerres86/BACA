BEGIN  
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',0,'MONITORA_EMAIL_CALRIS','Email de destino dos monitoramentos.','coaf@ailos.coop.br');
    
  COMMIT;
END;
/