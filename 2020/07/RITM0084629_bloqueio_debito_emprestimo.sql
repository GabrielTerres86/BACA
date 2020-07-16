/* conta 652.555-5 (Viacredi), contrato  1.485.346  */
BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = prm.dsvlrprm || ',(6525555,1485346)'
   WHERE prm.cdcooper = 1
     AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';
     
  COMMIT;
END;
