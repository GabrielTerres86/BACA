BEGIN
  
  UPDATE tbepr_consig_parcelas_tmp t
     SET t.nrdconta = 99934701 
   WHERE t.cdcooper = 7 
     AND t.nrdconta = 65234 
     AND t.nrctremp = 47787;    
            
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
