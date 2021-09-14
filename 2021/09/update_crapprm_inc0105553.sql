--Atualizar SMTP server, de exchange.cecred.coop.br para exchange.ailos.coop.br
--NMSISTEM, CDCOOPER, CDACESSO
UPDATE crapprm p
   SET p.dsvlrprm = 'exchange.ailos.coop.br'
 WHERE p.nmsistem = 'CRED'
   AND p.cdcooper = 0
   AND p.cdacesso = 'SMTP_SERVER';   
COMMIT;
