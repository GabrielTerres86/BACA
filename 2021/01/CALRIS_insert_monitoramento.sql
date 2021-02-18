BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',0,'MONITORA_CALRIS','Flag ativo/inativo para enviar email de monitoramentos do calculo de risco.','0');
    
  FOR cr_crapcop IN (SELECT cdcooper
                           ,flgativo
                       FROM crapcop) LOOP
    INSERT INTO crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED',cr_crapcop.cdcooper,'MONITORA_CALRIS','Flag ativo/inativo para enviar email de monitoramentos do calculo de risco.',cr_crapcop.flgativo);
  END LOOP;
  
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',0,'MONITORA_EMAIL_CALRIS','Email de destino dos monitoramentos.','joana.aguida@ailos.coop.br;thiago.rodrigues@ailos.coop.br;renan.oliveira@supero.com.br');
    
  COMMIT;
END;
/