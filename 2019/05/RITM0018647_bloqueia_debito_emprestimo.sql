UPDATE crapprm prm
   SET prm.dsvlrprm = prm.dsvlrprm || ',(6182550,276455)'
 WHERE prm.cdcooper = 1
   AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';
   
COMMIT;
