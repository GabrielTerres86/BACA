BEGIN
  UPDATE crapprm prm 
     SET prm.dsvlrprm = '75600'
   WHERE prm.cdcooper = 0 
     AND prm.nmsistem = 'CRED' 
     AND prm.cdacesso = 'HRFIM_PRC_RET_PAGFOR';      
  COMMIT; 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;    
END;
