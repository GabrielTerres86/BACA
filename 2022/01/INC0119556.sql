BEGIN
  
  UPDATE crawcrd SET
         cdgraupr = 5
  WHERE cdcooper = 11
        AND nrdconta = 223603 
        AND nrctrcrd = 144844;    
    
  UPDATE crawcrd SET
         cdgraupr = 6
  WHERE cdcooper = 11
        AND nrdconta = 223603 
        AND nrctrcrd = 144845;

commit;

END;
