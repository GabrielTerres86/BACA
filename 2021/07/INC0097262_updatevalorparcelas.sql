BEGIN
  UPDATE crawepr c
     SET vlpreemp = 218.16
   WHERE c.cdcooper = 1
     AND c.nrdconta = 9948333
     AND c.nrctremp = 4195837;
     
  UPDATE crappep c
     SET vlparepr = 218.16,
         vlsdvpar = 218.16,
         vlsdvsji = 218.16,
         vlsdvatu = 218.16,
         vljura60 = 218.16
   WHERE c.cdcooper = 1
     AND c.nrdconta = 9948333
     AND c.nrctremp = 4195837;
  COMMIT;
  
  EXCEPTION 
      WHEN OTHERS THEN
        ROLLBACK;
END;
