BEGIN
UPDATE crapprm p
SET p.dsvlrprm = 'katia.heckmann@ailos.coop.br'
WHERE
p.cdacesso LIKE '%EMAIL_TESTE%';
COMMIT;
END;