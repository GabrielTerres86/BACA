BEGIN
  
UPDATE crapprm t
set T.DSVLRPRM = 'fabricio.michelato@ailos.coop.br'
where T.CDACESSO  LIKE '%EMAIL_TESTE%';

COMMIT;
END;