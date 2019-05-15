BEGIN
 --
 --/
 INSERT INTO CRAPPRM
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
 VALUES
    ('CRED',
     1,
     'ERRO_EMAIL_ESTEIRA',
     'Destinatário(s) que receberão e-mail alertando que a proposta teve erro na passagem pela esteira',
     NULL);
     
  COMMIT;     
END;
