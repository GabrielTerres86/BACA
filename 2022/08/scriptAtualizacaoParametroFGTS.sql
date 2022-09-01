BEGIN  
  UPDATE cecred.crapprm
     SET dsvlrprm = 'A'
   WHERE cdacesso = 'FLG_PAG_FGTS_CXON'
     AND cdcooper IN (9,2,8,10,11,12,5,6,7,13,14);
  COMMIT;
END;