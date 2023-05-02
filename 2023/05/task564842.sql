BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = 'diego.siqueira@ailos.coop.br'
   WHERE p.cdacesso LIKE '%EMAIL_TESTE%';
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;


