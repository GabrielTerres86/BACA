DECLARE
  rw_crapdat datasCooperativa;   
BEGIN
  rw_crapdat := datasCooperativa(pr_cdcooper => 5); 
  
  UPDATE CECRED.crapsda a
     SET a.vlsddisp = 0
   WHERE a.cdcooper = 5
     AND a.nrdconta = 270059
     AND a.dtmvtolt >= rw_crapdat.dtmvcentral;

  UPDATE CECRED.crapsld b
     SET b.vlsddisp = 0
   WHERE b.cdcooper = 5
     AND b.nrdconta = 270059;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
