BEGIN
  
UPDATE craprac r r.vlbasapl = 0.01
 WHERE r.cdcooper = 1
   AND r.nrdconta = 6679935
   AND r.nraplica = 1;
      
COMMIT;

END;   
