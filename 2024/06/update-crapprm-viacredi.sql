BEGIN
  
UPDATE cecred.crapprm prm
  SET prm.dsvlrprm = ';04'
WHERE prm.cdcooper = 1
  AND prm.nmsistem = 'CRED'
  AND prm.cdacesso = 'PRM_HCONVE_CRPS387_IN'; 
  
COMMIT;
END;
