BEGIN
-- 1 / 7143559 / 2443166
  UPDATE crappep pep
     SET pep.vlparepr = 440.85
        ,pep.vlsdvpar = 440.85
        ,pep.vlsdvatu = 440.85
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 7143559
     AND pep.nrctremp = 2443166
     AND pep.nrparepr = 2
     ;
  UPDATE crappep pep
     SET pep.vlparepr = 440.26
        ,pep.vlsdvpar = 440.26
        ,pep.vlsdvatu = 440.26
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 7143559
     AND pep.nrctremp = 2443166
     AND pep.nrparepr = 3
     ;
  UPDATE crappep pep
     SET pep.vlparepr = 439.67
        ,pep.vlsdvpar = 439.67
        ,pep.vlsdvatu = 439.67
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 7143559
     AND pep.nrctremp = 2443166
     AND pep.nrparepr = 4
     ;
-- 1 / 9002650 / 2385210
  UPDATE crappep pep
     SET pep.vlparepr = 165.64
        ,pep.vlsdvpar = 165.64
        ,pep.vlsdvatu = 165.64
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 9002650
     AND pep.nrctremp = 2385210
     AND pep.nrparepr = 2
     ;
  UPDATE crappep pep
     SET pep.vlparepr = 165.43
        ,pep.vlsdvpar = 165.43
        ,pep.vlsdvatu = 165.43
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 9002650
     AND pep.nrctremp = 2385210
     AND pep.nrparepr = 3
     ;
-- 1 / 9601171 / 2473519
  UPDATE crappep pep
     SET pep.vlparepr = 121.46
        ,pep.vlsdvpar = 121.46
        ,pep.vlsdvatu = 121.46
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 9601171
     AND pep.nrctremp = 2473519
     AND pep.nrparepr = 2
     ;
  UPDATE crappep pep
     SET pep.vlparepr = 121.16
        ,pep.vlsdvpar = 121.16
        ,pep.vlsdvatu = 121.16
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 9601171
     AND pep.nrctremp = 2473519
     AND pep.nrparepr = 3
     ;
-- 1 / 6762395 / 2407042
  UPDATE crappep pep
     SET pep.vlparepr = 618.13
        ,pep.vlsdvpar = 618.13
        ,pep.vlsdvatu = 618.13
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 6762395
     AND pep.nrctremp = 2407042
     AND pep.nrparepr = 2
     ;
  UPDATE crappep pep
     SET pep.vlparepr = 616.51
        ,pep.vlsdvpar = 616.51
        ,pep.vlsdvatu = 616.51
   WHERE pep.cdcooper = 1
     AND pep.nrdconta = 6762395
     AND pep.nrctremp = 2407042
     AND pep.nrparepr = 3
     ;

  COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;
