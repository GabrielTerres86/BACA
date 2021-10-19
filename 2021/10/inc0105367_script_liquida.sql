BEGIN

  UPDATE crappep
     SET vlsdvatu = 0
        ,inliquid = 1
   WHERE inliquid = 0
     AND cdcooper = 13
     AND nrdconta = 500100
     AND nrctremp = 129765;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
