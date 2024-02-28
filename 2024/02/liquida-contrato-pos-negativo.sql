BEGIN
        
  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE (cdcooper, nrdconta, nrctremp, nrparepr) IN (
         (16,731935,545521,6)
         ,(1,10814264,2978569,38)
         ,(16,811149,528002,24)
         ,(16,609307,453824,33)
       );

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
