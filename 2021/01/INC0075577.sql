UPDATE crappep pep
   SET pep.vlparepr = 374.88
 WHERE pep.cdcooper = 14
   AND pep.nrdconta = 81523
	 AND pep.nrctremp = 13711
	 AND pep.nrparepr = 2;

UPDATE crappep pep
   SET pep.vlparepr = 374.81
	    ,pep.vlsdvpar = 374.81 - pep.vlpagpar
		  ,pep.vlsdvatu = 374.81 - pep.vlpagpar
 WHERE pep.cdcooper = 14
   AND pep.nrdconta = 81523
	 AND pep.nrctremp = 13711
	 AND pep.nrparepr = 3;

UPDATE crapepr epr
   SET epr.vlpreemp = 374.81
 WHERE epr.cdcooper = 14
   AND epr.nrdconta = 81523
	 AND epr.nrctremp = 13711;

COMMIT;
