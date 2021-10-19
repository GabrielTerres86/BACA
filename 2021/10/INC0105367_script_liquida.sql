BEGIN

  UPDATE crappep
     SET vlsdvatu = 0
        ,inliquid = 1
   WHERE inliquid = 0
     AND cdcooper = 13
     AND nrdconta = 500100
     AND nrparepr in (4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33
                     ,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,64)
     AND nrctremp = 129765;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
