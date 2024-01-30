BEGIN

  UPDATE cecred.crapprm
     SET dsvlrprm =  '15,504,3665'
 WHERE nmsistem = 'CRED'
   AND cdcooper = 0
   AND cdacesso = 'HIST_BLOQ_INTEGRA';
   
  COMMIT;
  
END;   
