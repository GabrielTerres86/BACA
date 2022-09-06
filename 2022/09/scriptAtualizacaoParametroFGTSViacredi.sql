BEGIN  
  UPDATE cecred.crapprm
     SET dsvlrprm = 'A'
   WHERE cdacesso = 'FLG_PAG_FGTS_CXON'
     AND cdcooper IN (1,16);
  COMMIT;
END;