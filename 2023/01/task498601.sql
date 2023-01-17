BEGIN
  UPDATE cecred.crappep pep
     SET pep.vlparepr = 146.68,
         pep.vlsdvpar = 146.68,
         pep.vlsdvsji = 146.68
   WHERE pep.nrdconta = 15944123
     AND pep.nrctremp = 44144
     AND pep.cdcooper = 10;
   
  UPDATE cecred.crawepr w
     SET w.vlpreemp = 146.68,
         w.vlpreori = 146.68,
         w.vliofepr = 64.54
   WHERE w.nrdconta = 15944123
     AND w.nrctremp = 44144
     AND w.cdcooper = 10;

  UPDATE cecred.crapepr epr
     SET epr.vlpreemp = 146.68,
         epr.vliofepr = 64.54,
         epr.vltariof = 64.54
   WHERE epr.nrdconta = 15944123
     AND epr.nrctremp = 44144
     AND epr.cdcooper = 10;      
           
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
