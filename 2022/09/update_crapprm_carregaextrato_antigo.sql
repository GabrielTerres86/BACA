BEGIN          
  UPDATE crapprm cp 
     SET cp.dsvlrprm = 0
   WHERE cp.nmsistem = 'CRED'
     AND cp.cdacesso = 'QBRSIG_EXTRATO'             
     AND cp.cdcooper = 0;
     
  COMMIT;
END;     
 
