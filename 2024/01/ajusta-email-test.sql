BEGIN
  
   UPDATE crapprm p
   SET p.dsvlrprm = 'amcom-derick.vareschi@ailos.coop.br'
   WHERE
   p.cdacesso LIKE '%EMAIL_TESTE%';
    
    COMMIT;
END;
