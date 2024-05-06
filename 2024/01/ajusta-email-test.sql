BEGIN
  
   UPDATE crapprm p
   SET p.dsvlrprm = 'emanuele.schatz@ailos.coop.br'
   WHERE
   p.cdacesso LIKE '%EMAIL_TESTE%';
    
    COMMIT;
END;
