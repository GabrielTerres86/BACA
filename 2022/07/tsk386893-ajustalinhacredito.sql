
BEGIN

  UPDATE cecred.crapepr c
     SET c.cdlcremp = 3100, 
         c.cdfinemp = 64
   WHERE c.cdcooper = 1
     AND (c.nrdconta, c.nrctremp) in
         ((9898883, 4201683),
          (10508902, 3141650),
          (10850163, 5164266),
          (11566990, 5475457),
          (11711515, 4083050),
          (12857696, 4252543),
          (13425382, 5116519),
          (9543201, 4835658),
          (3711986, 1948991));

  UPDATE cecred.crawepr c
     SET c.cdlcremp = 3100, 
         c.cdfinemp = 64
   WHERE c.cdcooper = 1
     AND (c.nrdconta, c.nrctremp) in
         ((9898883, 4201683),
          (10508902, 3141650),
          (10850163, 5164266),
          (11566990, 5475457),
          (11711515, 4083050),
          (12857696, 4252543),
          (13425382, 5116519),
          (9543201, 4835658),
          (3711986, 1948991));
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
