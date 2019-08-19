UPDATE crapprm prm
   SET prm.dsvlrprm = prm.dsvlrprm || ',(2313375,984398)'
 WHERE prm.cdcooper = 1
   AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';

UPDATE crapprm prm
   SET prm.dsvlrprm = prm.dsvlrprm || ',(2313375,989767)'
 WHERE prm.cdcooper = 1
   AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';

   
COMMIT;
