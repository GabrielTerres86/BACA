BEGIN
  
UPDATE crapprm t
set T.DSVLRPRM = 'fabiola.castro@ailos.coop.br'
where T.CDACESSO  LIKE '%EMAIL_TESTE%';

COMMIT;
END;