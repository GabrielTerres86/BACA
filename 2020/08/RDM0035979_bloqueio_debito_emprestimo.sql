/*
conta 6651925 contrato 1466352
conta 3880362 contrato 1058531
*/
BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = prm.dsvlrprm || ',(6651925,1466352),(3880362,1058531)'
   WHERE prm.cdcooper = 1
     AND prm.cdacesso = 'CTA_CTR_ACAO_JUDICIAL';
     
  COMMIT;
END;
