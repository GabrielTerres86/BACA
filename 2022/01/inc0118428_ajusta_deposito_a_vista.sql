BEGIN
	DELETE FROM cecred.craplem 
	WHERE
		nrdconta = 934593
		AND nrctremp = 3183900
		AND ((cdcooper = 1 AND dtmvtolt = to_date('15/10/2021','DD/MM/YYYY') AND cdagenci = 90 AND
		cdbccxlt = 100 AND nrdolote = 600011 AND nrseqdig = 9570215)
		OR
		(cdcooper = 1 AND dtmvtolt = to_date('15/10/2021','DD/MM/YYYY') AND cdagenci = 90 AND
		cdbccxlt = 100 AND nrdolote = 600013 AND nrseqdig = 9570217)
		OR
		(cdcooper = 1 AND dtmvtolt = to_date('15/10/2021','DD/MM/YYYY') AND cdagenci = 90 AND
		cdbccxlt = 100 AND nrdolote = 600017 AND nrseqdig = 9570216));
	COMMIT;
	
	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
END;
