DECLARE
  
  
BEGIN
 
 UPDATE cecred.crapprm SET dsvlrprm = '2' WHERE nmsistem = 'CRED' AND cdcooper IN (2,3,5,6,7,9,11,13,14) AND cdacesso = 'EXECUTAR_CARGA_CENTRAL';
 
 UPDATE gestaoderisco.tbrisco_central_carga c 
    SET c.cdstatus = 7
  WHERE cdcooper IN (1,2,3,5,6,7,9,11,13,14,16)  
    AND c.CDSTATUS <> 7;

 COMMIT;
  
END;
