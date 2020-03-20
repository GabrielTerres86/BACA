BEGIN
  
DELETE FROM  crapprm prm
WHERE prm.cdcooper = 12 
  AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';

COMMIT;

END;
