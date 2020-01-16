
UPDATE crapprm p 
   SET p.dsvlrprm = p.dsvlrprm || ';vendascomcartoes@ailos.coop.br'
 WHERE p.cdacesso = 'EMAIL_DIVERGENCIAS_RET25';

UPDATE crapprm p 
   SET p.dsvlrprm = p.dsvlrprm || ';vendascomcartoes@ailos.coop.br'
 WHERE p.cdacesso = 'EMAIL_DIVERGENCIAS_RET23';
 
UPDATE crapprm p 
   SET p.dsvlrprm = p.dsvlrprm || ';vendascomcartoes@ailos.coop.br'
 WHERE p.cdacesso = 'EMAIL_DIVERGENCIAS_RET33'; 
 
 
COMMIT;
