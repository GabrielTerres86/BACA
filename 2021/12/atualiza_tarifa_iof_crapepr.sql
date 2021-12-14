BEGIN
UPDATE crapepr
  SET vltarifa = 0
     ,vliofepr = 0
WHERE cdcooper = 1
 AND nrdconta = 3033015
 AND nrctremp = 4657382;
COMMIT;
END;
