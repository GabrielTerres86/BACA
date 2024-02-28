BEGIN
        
  UPDATE CECRED.crappep
     SET inliquid = 1,        
         vlsdvpar = 0,
         vlsdvatu = 0
   WHERE (cdcooper, nrdconta, nrctremp) IN (
         (16,731935,545521)
         ,(1,10814264,2978569)
         ,(16,811149,528002)
         ,(16,609307,453824)

       );

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
