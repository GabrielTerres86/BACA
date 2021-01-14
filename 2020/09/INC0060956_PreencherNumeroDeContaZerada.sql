DECLARE
  
  vr_nrdconta NUMBER := CECRED.fn_sequence(pr_nmtabela => 'CRAPASS'
                                          ,pr_nmdcampo => 'NRDCONTA'
                                          ,pr_dsdchave => 1);

BEGIN
  
  UPDATE crapass t
     SET t.nrdconta = vr_nrdconta
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;
  
  UPDATE crapttl t
     SET t.nrdconta = vr_nrdconta
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;
 
  UPDATE crapenc t
     SET t.nrdconta = vr_nrdconta
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;

  UPDATE craptfc t
     SET t.nrdconta = vr_nrdconta
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;
  
  UPDATE crapcem t
     SET t.nrdconta = vr_nrdconta
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;
  
  UPDATE crapbem t
     SET t.nrdconta = vr_nrdconta
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;
    
  COMMIT;
    
END;