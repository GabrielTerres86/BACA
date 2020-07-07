/* (Credcrea) conta nº 21318, contrato 15043. */
BEGIN
   DELETE FROM crapprm prm
   WHERE prm.cdcooper = 7
   AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';  
 
  COMMIT;
END;

