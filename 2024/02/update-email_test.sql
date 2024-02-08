BEGIN

  update crapprm
  set dsvlrprm = 'amilton.machado@ailos.coop.br'
  where cdacesso = 'EMAIL_TESTE'
  and progress_recid = 105;
  
   COMMIT;
END;
