BEGIN
  
  UPDATE crappep p
     SET p.vlparepr = 3047.76
        ,p.vlsdvpar = 3047.76
        ,p.vlsdvatu = 3047.76
   WHERE p.cdcooper = 14
     AND p.nrdconta = 113476 
     AND p.nrctremp = 12319
     AND p.nrparepr IN (11, 12);
  
  UPDATE crapepr e
     SET e.vlpreemp = 3047.76
   WHERE e.cdcooper = 14
     AND e.nrdconta = 113476 
     AND e.nrctremp = 12319;
  
  COMMIT;  

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
    
end;
