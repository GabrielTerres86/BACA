BEGIN
  
  UPDATE crapass t
     SET t.nrdconta = CECRED.fn_sequence(pr_nmtabela => 'CRAPASS'
                                        ,pr_nmdcampo => 'NRDCONTA'
                                        ,pr_dsdchave => 1)
   WHERE t.cdcooper = 1
     AND t.nrdconta = 0;
    
  COMMIT;
    
END;