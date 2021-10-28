BEGIN
  UPDATE  crapprm prm
  SET prm.dsvlrprm =  '10'
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 16
           AND prm.cdacesso = 'QTD_PARALE_CRPS720' ;
  COMMIT;
END;