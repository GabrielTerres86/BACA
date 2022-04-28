BEGIN
  UPDATE credito.tbcred_pronampe_contrato
     SET tpsituacaohonra = 2
   WHERE cdcooper = 1
     AND nrdconta = 8460361
     AND nrcontrato = 2900500; 
     
  UPDATE credito.tbcred_pronampe_contrato
     SET tpsituacaohonra = 2
   WHERE cdcooper = 1
     AND nrdconta = 8946787
     AND nrcontrato = 2900856;           
     
  UPDATE credito.tbcred_pronampe_contrato
     SET tpsituacaohonra = 2
   WHERE cdcooper = 1
     AND nrdconta = 8946787
     AND nrcontrato = 2980915;      
     
  UPDATE credito.tbcred_pronampe_contrato
     SET tpsituacaohonra = 2
   WHERE cdcooper = 1
     AND nrdconta = 9056556
     AND nrcontrato = 2898382;     
     
  UPDATE credito.tbcred_pronampe_contrato
     SET tpsituacaohonra = 2
   WHERE cdcooper = 1
     AND nrdconta = 10490183
     AND nrcontrato = 2900549;  
     
  UPDATE credito.tbcred_pronampe_contrato
     SET tpsituacaohonra = 2
   WHERE cdcooper = 1
     AND nrdconta = 29556
     AND nrcontrato = 233200;   
     
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;    
                   
