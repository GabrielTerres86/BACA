BEGIN
UPDATE crapprm
   set dsvlrprm = 'jefferson.luiz@ailos.coop.br'
 WHERE cdacesso = 'MONITORA_EMAIL_CALRIS';
 COMMIT;
END;